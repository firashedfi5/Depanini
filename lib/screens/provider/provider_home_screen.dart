import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/post_model.dart';
import 'package:depanini/screens/common/notifications_screen.dart';
import 'package:depanini/screens/provider/provider_home/show_post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  // List<PostModel> _postListed = [];
  // var _isLoading = true;
  // String? _error;

  Future<List<PostModel>> _loadPosts() async {
    // Step 1: Get current user
    final user = _auth.currentUser!;

    // Step 2: Fetch domaine from Firestore
    final userDoc =
        await _firestore.collection("prestataires").doc(user.uid).get();
    final userData = userDoc.data();

    if (userData == null || !userData.containsKey('Domaine')) {
      throw Exception("Domaine non trouvé pour l'utilisateur");
    }

    final domaine = userData['Domaine'];

    // Step 3: Build URL with domaine
    final url = Uri.http('10.0.2.2:3300', 'afficher-tous-annonces/$domaine');

    // Step 4: Fetch from backend
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Échec de récupération des données.');
    }

    final List<dynamic> listData = json.decode(response.body);
    return listData
        .map(
          (post) => PostModel(
            id: post["id"],
            uid: post["uid"],
            username: post["username"],
            phoneNumber: post["phone_number"],
            profilPicture: post["profil_picture"],
            description: post["description"],
            service: post["service"],
            date: post["date"],
          ),
        )
        .toList();
  }

  Future<List<PostModel>> _foundedPosts = Future.value([]);

  late Stream<DocumentSnapshot> userStream;
  final user = _auth.currentUser!;

  @override
  void initState() {
    super.initState();
    userStream =
        _firestore.collection("prestataires").doc(user.uid).snapshots();
    _foundedPosts = _loadPosts();
  }

  // ***********Search************************
  void searchPost(String search) {
    String searchLower = search.toLowerCase().trim();

    // If search input is empty, return all users
    if (searchLower.isEmpty) {
      _loadPosts().then((astuces) {
        setState(() {
          _foundedPosts = Future.value(astuces);
        });
      });
      return;
    }

    _loadPosts().then((post) {
      setState(() {
        _foundedPosts = Future.value(
          post.where((post) {
            return post.description.toLowerCase().contains(searchLower);
          }).toList(),
        );
      });
    });
  }

  // ***********Search************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                pinned: true,
                floating: true,
                // snap: true,
                expandedHeight: 120,
                title: StreamBuilder<DocumentSnapshot>(
                  stream: userStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text("Aucune donnée trouvée"));
                    }

                    // Extract user data from DocumentSnapshot
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;

                    return Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              foregroundImage:
                                  userData['Photo de profile'] != null
                                      ? NetworkImage(
                                        userData['Photo de profile'],
                                      )
                                      : null,
                              child:
                                  userData['Photo de profile'] == null
                                      ? const Icon(
                                        Icons.person,
                                        size: 70,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    text: 'Salut, ', // Normal text
                                    style:
                                        Theme.of(context)
                                            .textTheme
                                            .titleMedium, // Default style
                                    children: [
                                      TextSpan(
                                        text:
                                            userData['Nom d\'utilisateur'], // Bold text
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.pin_drop_outlined, size: 17),
                                    SizedBox(width: 3),
                                    Text(
                                      'Tunis, Tunisie',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotificationsScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.notifications),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(65),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: SizedBox(
                          height: 35,
                          width: 360,
                          child: SearchBar(
                            leading: Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            // controller: searchController,
                            onChanged: (value) {
                              searchPost(value);
                            },
                            onSubmitted: (value) {
                              searchPost(value);
                            },
                            hintText: 'Rechercher une publication ?',
                            backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryFixedVariant
                                  : const Color.fromARGB(255, 228, 216, 240),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: FutureBuilder<List<PostModel>>(
            future: _foundedPosts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Aucun prestataire ajouté pour le moment'),
                );
              }
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ShowPostScreen(id: snapshot.data![index].id),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 150,
                      width: 350,
                      child: Card(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest
                                : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // ClipRRect(
                              //   borderRadius: BorderRadius.circular(15.0),
                              //   child: Image.network(
                              //     snapshot.data![index].profilPicture,
                              //     height: 120,
                              //     width: 120,
                              //     fit: BoxFit.cover,
                              //   ),
                              // ),
                              // SizedBox(width: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data![index].description,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    snapshot.data![index].date,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: 2),
                                  Text(snapshot.data![index].service),
                                  // Text(snapshot.data![index].experience),
                                  // Text(snapshot.data![index].phoneNumber),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
