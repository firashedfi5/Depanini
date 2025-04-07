import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/constants/domains.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/screens/client/home/provider_info_screen.dart';
import 'package:depanini/screens/common/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:depanini/data/word_to_field.dart';
import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final List<Domains> _domains = Domains.values;
  int selected = -1;

  Future<List<ProviderAccountModel>> _foundedUsers = Future.value([]);

  Future<List<ProviderAccountModel>> getAllData() async {
    final data = await _firestore.collection("prestataires").get();
    final snapshot =
        data.docs.map((doc) => ProviderAccountModel.fromSnapshot(doc)).toList();
    return snapshot;
  }

  late Stream<DocumentSnapshot> userStream;
  final user = _auth.currentUser!;

  @override
  void initState() {
    super.initState();
    userStream =
        _firestore.collection("prestataires").doc(user.uid).snapshots();
    _foundedUsers = getAllData();
  }

  // ***********Search************************
  void searchUsers(String search) {
    String searchLower = search.toLowerCase().trim();

    // If search input is empty, return all users
    if (searchLower.isEmpty) {
      getAllData().then((users) {
        setState(() {
          _foundedUsers = Future.value(users);
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

    getAllData().then((users) {
      setState(() {
        _foundedUsers = Future.value(
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
                expandedHeight: 200,
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
                  preferredSize: Size.fromHeight(125),
                  child: Column(
                    children: [
                      // SizedBox(height: 25),
                      SizedBox(
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
                      SizedBox(height: 16),
                      SizedBox(
                        height: 74,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: _domains.length,
                          itemBuilder: (context, index) {
                            return customRadioButton(
                              label: _domains[index].name,
                              index: index,
                              imageURL: _domains[index].imageURL,
                            );
                          },
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
            future: _foundedUsers,
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

  Widget customRadioButton({
    required String label,
    required String imageURL,
    required int index,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor:
            selected == index
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.transparent,
      ),
      onPressed: () {
        setState(() {
          // Toggle selection: if already selected, unselect (set to null or -1)
          if (selected == index) {
            selected = -1; // or `null` if your selected variable is nullable
            searchUsers('');
          } else {
            selected = index;
            searchUsers(_domains[index].name); // Only search on selection
          }
          dev.log(selected.toString());
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            foregroundImage:
                imageURL.isNotEmpty ? NetworkImage(imageURL) : null,
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
