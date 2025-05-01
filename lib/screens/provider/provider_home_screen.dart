import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/place.dart';
import 'package:depanini/models/post_model.dart';
import 'package:depanini/screens/common/map.dart';
import 'package:depanini/screens/common/notifications_screen.dart';
import 'package:depanini/screens/provider/provider_home/show_post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

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
    try {
      final user = _auth.currentUser!;

      final userDoc =
          await FirebaseFirestore.instance
              .collection("prestataires")
              .doc(user.uid)
              .get();
      final userData = userDoc.data();

      if (userData == null || !userData.containsKey('Domaine')) {
        throw Exception("Domaine non trouvé pour l'utilisateur.");
      }

      final String domaine = userData['Domaine'];

      final querySnapshot =
          await _firestore
              .collection("annonces")
              .where("service", isEqualTo: domaine)
              .get();

      final posts =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return PostModel(
              id: doc.id,
              email: data["email"],
              uid: data["uid"],
              username: data["username"],
              phoneNumber: data["phone_number"],
              profilPicture: data["profil_picture"],
              description: data["description"],
              service: data["service"],
              date: data["date"],
              image1: data["imageURL_1"],
              image2: data["imageURL_2"],
              image3: data["imageURL_3"],
              image4: data["imageURL_4"],
            );
          }).toList();

      return posts;
    } catch (e) {
      throw Exception("Erreur de chargement des annonces : $e");
    }
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
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MapScreen(
                                          location: PlaceLocation(
                                            address: userData['Localisation'],
                                            latitude:
                                                userData['Latitude&Longitude']
                                                    .latitude,
                                            longitude:
                                                userData['Latitude&Longitude']
                                                    .longitude,
                                          ),
                                          isSelecting: false,
                                        ),
                                  ),
                                );
                              },
                              child: Column(
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
                                      SizedBox(
                                        width: 230,
                                        child: Text(
                                          userData['Localisation'],
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                return Center(
                  child: Text(
                    'Aucune annonce ajouté pour le moment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                    child: Card(
                      elevation: 2,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withAlpha(100)
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data![index].description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.outlineVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        snapshot.data![index].date,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outlineVariant,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        height: 4,
                                        width: 4,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        snapshot.data![index].service,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
