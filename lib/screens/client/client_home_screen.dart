import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/screens/client/home/provider_info_screen.dart';
// import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/widgets/category_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

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
    userStream = _firestore.collection("clients").doc(user.uid).snapshots();
    _foundedUsers = getAllData();
    searchController.addListener(() {
      searchUsers(); // Trigger the search function whenever the input changes
    });
  }

  // ***********Search************************

  Map<String, String> wordToField = {
    // Mécanique
    'voiture': 'mécanique',
    'moteur': 'mécanique',
    'vitesse': 'mécanique',
    'pneu': 'mécanique',
    // Informatique
    'ordinateur': 'informatique',
    'internet': 'informatique',
    'clavier': 'informatique',
    'écran': 'informatique',
    // Jardinage
    'plante': 'jardinage',
    'arbre': 'jardinage',
    'fleur': 'jardinage',
    'graines': 'jardinage',
  };
  void searchUsers() {
    String searchLower = searchController.text.toLowerCase().trim();

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
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_rounded)),
        ],
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
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  foregroundImage:
                      userData['Photo de profile'] != null
                          ? NetworkImage(userData['Photo de profile'])
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
                            Theme.of(
                              context,
                            ).textTheme.titleMedium, // Default style
                        children: [
                          TextSpan(
                            text: userData['Nom d\'utilisateur'], // Bold text
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
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
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall!.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bonjour, que faut-il réparer ?',
                  textAlign: TextAlign.left,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                height: 40,
                // width: 350,
                child: SearchBar(
                  leading: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  controller: searchController,
                  hintText: 'Search',
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 43, 43, 49)
                        : const Color.fromARGB(255, 236, 229, 243),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categories',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CategoryItem(
                      imagePath: 'assets/images/electricite.jpg',
                      label: 'Electricite',
                    ),
                    SizedBox(width: 15),
                    CategoryItem(
                      imagePath: 'assets/images/jardinage.jpg',
                      label: 'Jardinage',
                    ),
                    SizedBox(width: 15),
                    CategoryItem(
                      imagePath: 'assets/images/plomberie.jpg',
                      label: 'Plomberie',
                    ),
                    SizedBox(width: 15),
                    InkWell(
                      onTap: () {
                        searchController.text = 'mécanique';
                      },
                      child: CategoryItem(
                        imagePath: 'assets/images/mecanique.jpg',
                        label: 'Mécanique',
                      ),
                    ),
                    SizedBox(width: 15),
                    InkWell(
                      onTap: () {
                        searchController.text = 'informatique';
                      },
                      child: CategoryItem(
                        imagePath: 'assets/images/informatique.jpg',
                        label: 'Infomatique',
                      ),
                    ),
                    SizedBox(width: 15),
                    CategoryItem(imagePath: '', label: 'bla bla'),
                    SizedBox(width: 15),
                    CategoryItem(imagePath: '', label: 'bla bla'),
                    SizedBox(width: 15),
                    CategoryItem(imagePath: '', label: 'bla bla'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<List<ProviderAccountModel>>(
                future: _foundedUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
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
                                    ? Color.fromARGB(255, 43, 43, 49)
                                    : const Color.fromARGB(255, 236, 229, 243),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.network(
                                    snapshot.data![index].profilPicture,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Column(
                                  children: [
                                    // Text(snapshot.data![index].email),
                                    Text(snapshot.data![index].username),
                                    Text(snapshot.data![index].diplome),
                                    Text(snapshot.data![index].description),
                                    Text(snapshot.data![index].domaine),
                                    Text(snapshot.data![index].experience),
                                    Text(snapshot.data![index].phoneNumber),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}
