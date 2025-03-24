import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<DocumentSnapshot> userStream;
  final user = _auth.currentUser!;

  @override
  void initState() {
    super.initState();
    userStream = _firestore.collection("clients").doc(user.uid).snapshots();
  }

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
              ],
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              width: 350,
              child: SearchBar(
                leading: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintText: 'Search',
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).brightness == Brightness.dark
                      ? Color.fromARGB(255, 43, 43, 49) // Dark theme color
                      : const Color.fromARGB(255, 236, 229, 243),
                ),
              ),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        foregroundImage: AssetImage(
                          'assets/images/electricite.jpg',
                        ),
                      ),
                      Text(
                        'Electricité',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        foregroundImage: AssetImage(
                          'assets/images/jardinage.jpg',
                        ),
                      ),
                      Text(
                        'Jardinage',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        foregroundImage: AssetImage(
                          'assets/images/plomberie.jpg',
                        ),
                      ),
                      Text(
                        'Plomberie',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        foregroundImage: AssetImage(
                          'assets/images/mecanique.jpg',
                        ),
                      ),
                      Text(
                        'Mécanique',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        foregroundImage: AssetImage(
                          'assets/images/informatique.jpg',
                        ),
                      ),
                      Text(
                        'Infomatique',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  CircleAvatar(
                    radius: 25,
                    // foregroundImage: AssetImage('assets/images/'),
                  ),
                  SizedBox(width: 15),
                  CircleAvatar(
                    radius: 25,
                    // foregroundImage: AssetImage('assets/images/'),
                  ),
                  SizedBox(width: 15),
                  CircleAvatar(
                    radius: 25,
                    // foregroundImage: AssetImage('assets/images/'),
                  ),
                ],
              ),
            ),
            ListView.builder(itemBuilder: itemBuilder)
          ],
        ),
      ),
    );
  }
}
