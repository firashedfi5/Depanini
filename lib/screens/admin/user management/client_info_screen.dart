import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/client_account_model.dart';
import 'package:depanini/models/post_model.dart';
import 'package:depanini/widgets/image_container.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class ClientInfoScreen extends StatefulWidget {
  final ClientModel clientData;

  const ClientInfoScreen({super.key, required this.clientData});

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen> {
  Future<List<PostModel>> _loadPosts() async {
    final snapshot =
        await _firestore
            .collection('annonces')
            .where('uid', isEqualTo: widget.clientData.uid)
            .orderBy('createdAt', descending: true)
            .get();

    final List<PostModel> loadedPosts =
        snapshot.docs.map((doc) {
          final data = doc.data();

          return PostModel(
            postId: data["post_id"],
            email: data["email"],
            uid: data["uid"],
            username: data["username"],
            phoneNumber: data["phone_number"],
            profilPicture: data["profil_picture"],
            description: data["description"],
            service: data["service"],
            date: data["date"],
            createdAt: data["createdAt"],
            image1: data["imageURL_1"],
            image2: data["imageURL_2"],
            image3: data["imageURL_3"],
            image4: data["imageURL_4"],
          );
        }).toList();

    return loadedPosts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Info')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withAlpha(100)
                        : Theme.of(context).colorScheme.secondaryContainer,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.network(
                        widget.clientData.profilPicture!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            widget.clientData.username!,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.clientData.role!,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Text('Diplôme: ${snapshot.data!.diplome}'),
                          Text.rich(
                            TextSpan(
                              text: 'Numéro de téléphone: ',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ), // Default style
                              children: [
                                TextSpan(
                                  text: widget.clientData.phoneNumber!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: 'Email: ',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ), // Default style
                              children: [
                                TextSpan(
                                  text: widget.clientData.email!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: 'Adresse: ',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ), // Default style
                              children: [
                                TextSpan(
                                  text: widget.clientData.localisation!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Post List
              Card(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withAlpha(100)
                        : Theme.of(context).colorScheme.secondaryContainer,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textAlign: TextAlign.start,
                        'Annonces',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 10),
                      FutureBuilder(
                        future: _loadPosts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 150,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            return const SizedBox(
                              height: 150,
                              child: Center(
                                child: Text(
                                  'Erreur lors du chargement des annonces',
                                ),
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const SizedBox(
                              height: 150,
                              child: Center(
                                child: Text('Aucun annonce disponible'),
                              ),
                            );
                          }

                          final posts = snapshot.data!;

                          return SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Text(post.description),
                                        Text(post.service),
                                        Text(post.date),
                                        // SizedBox(
                                        //   height: 50,
                                        //   child: ListView.separated(
                                        //     scrollDirection: Axis.horizontal,
                                        //     itemCount: 4,
                                        //     separatorBuilder:
                                        //         (_, __) =>
                                        //             const SizedBox(width: 12),
                                        //     itemBuilder: (context, imgIndex) {
                                        //       final images = [
                                        //         post.image1,
                                        //         post.image2,
                                        //         post.image3,
                                        //         post.image4,
                                        //       ];
                                        //       return ClipRRect(
                                        //         borderRadius:
                                        //             BorderRadius.circular(12),
                                        //         child: ImageContainer(
                                        //           height: 65,
                                        //           width: 85,
                                        //           imageUrl: images[imgIndex],
                                        //           // placeholder: Icons.photo_library_outlined,
                                        //         ),
                                        //       );
                                        //     },
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
