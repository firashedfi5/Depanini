import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/constants/domains.dart';
import 'package:depanini/models/astuce_model.dart';
import 'package:depanini/models/post_model.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/screens/client/home/provider_info_screen.dart';
import 'package:depanini/screens/common/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:depanini/data/word_to_field.dart';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  List<PostModel> _postListed = [];
  var _isLoading = true;
  String? _error;

  Future<List<AstuceModel>> _loadPosts() async {
    final url = Uri.http(
      '10.0.2.2:3300',
      'afficher-annonces/${_auth.currentUser!.uid}',
    );
    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error =
              'Echec de récupération des données. Veuillez réessayer plus tard.';
        });
      }

      // Decode the JSON response correctly as a List
      final List<dynamic> listData = json.decode(response.body);

      final List<PostModel> loadedPosts =
          listData.map((post) {
            return PostModel(
              id: post["id"],
              uid: post["uid"],
              description: post["description"],
              service: post["service"],
              date: post["date"],
              image1: post["imageURL_1"],
              image2: post["imageURL_2"],
              image3: post["imageURL_3"],
              image4: post["imageURL_4"],
            );
          }).toList();
      setState(() {
        _postListed = loadedPosts;
        _isLoading = false;
      });
    } catch (err) {
      if (mounted) {
        setState(() {
          _error =
              'Echec de récupération des données. Veuillez réessayer plus tard.';
        });
      }
    }
  }

  Future<List<ProviderAccountModel>> _foundedAstuces = Future.value([]);

  late Stream<DocumentSnapshot> userStream;
  final user = _auth.currentUser!;

  @override
  void initState() {
    super.initState();
    userStream =
        _firestore.collection("prestataires").doc(user.uid).snapshots();
    _foundedAstuces = _loadPosts();
  }

  // ***********Search************************
  void searchUsers(String search) {
    String searchLower = search.toLowerCase().trim();

    // If search input is empty, return all users
    if (searchLower.isEmpty) {
      _loadPosts().then((users) {
        setState(() {
          _foundedAstuces = Future.value(users);
        });
      });
      return;
    }

    // Check if the search term matches part of any keyword in the map
    String mappedField = '';
    wordToField.forEach((key, value) {
      if (key.contains(searchLower)) {
        mappedField = value;
      }
    });

    // If no match is found in the map, use the original search term
    mappedField = mappedField.isEmpty ? searchLower : mappedField;

    _loadPosts().then((users) {
      setState(() {
        _foundedAstuces = Future.value(
          users.where((user) {
            return user.domaine.toLowerCase().contains(mappedField) ||
                user.username.toLowerCase().contains(mappedField);
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
                              searchUsers(value);
                            },
                            onSubmitted: (value) {
                              searchUsers(value);
                            },
                            hintText: 'Que faut-il réparer ?',
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
          child: FutureBuilder<List<ProviderAccountModel>>(
            future: _foundedAstuces,
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
                              (context) => ProviderInfoScreen(
                                email: snapshot.data![index].email,
                              ),
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  snapshot.data![index].profilPicture,
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text(snapshot.data![index].email),
                                  Text(
                                    snapshot.data![index].username,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  SizedBox(height: 4),
                                  // Text(snapshot.data![index].diplome),
                                  Text(
                                    snapshot.data![index].description,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: 2),
                                  Text(snapshot.data![index].domaine),
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
