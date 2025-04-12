import 'dart:convert';

// import 'package:depanini/screens/client/posts/edit_post_screen.dart';
import 'package:depanini/screens/client/posts/edit_post_screen.dart';
import 'package:depanini/screens/client/posts/new_post_screen.dart';
import 'package:depanini/widgets/image_container.dart';
import 'package:flutter/material.dart';
import 'package:depanini/models/post_model.dart';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';

final _auth = FirebaseAuth.instance;

class ClientPostScreen extends StatefulWidget {
  const ClientPostScreen({super.key});

  @override
  State<ClientPostScreen> createState() => _ClientPostScreenState();
}

class _ClientPostScreenState extends State<ClientPostScreen> {
  List<PostModel> _postListed = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  // *****************HTTP Response*************************
  void _loadPosts() async {
    final url = Uri.http(
      '192.168.1.11:3300',
      'afficher-annonces/${_auth.currentUser!.uid}',
    ); // Virtual Device: 10.0.2.2 - Actual Device: 192.168.1.11 (ipconfig -> IPv4)
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
              email: post["email"],
              uid: post["uid"],
              username: post["username"],
              phoneNumber: post["phone_number"],
              profilPicture: post["profil_picture"],
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
  // ***********************************************

  void _addPost() async {
    await Navigator.of(
      context,
    ).push<PostModel>(MaterialPageRoute(builder: (context) => NewPostScreen()));
    _loadPosts();
    dev.log("Annonce crée");
  }

  void _removePost(PostModel post) {
    // final postIndex = _postListed.indexOf(post);
    final deleteUrl = Uri.http(
      '192.168.1.11:3300',
      'supprimer-annonces/${post.id}',
    );

    // Remove from UI
    setState(() {
      _postListed.remove(post);
    });

    http.delete(deleteUrl); // optional: await this if needed
    dev.log("Annonce supprimée");

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        content: Text('Annonce supprimée'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            // Add back to UI
            setState(() {
              _postListed.insert(0, post);
            });

            // Re-add to server using original structure
            final restoreUrl = Uri.http(
              '192.168.1.11:3300',
              'ajouter-annonces',
            );

            await http.post(
              restoreUrl,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'uid': post.uid,
                'email': post.email,
                'username': post.username,
                'phone_number': post.phoneNumber,
                'profil_picture': post.profilPicture,
                'description': post.description,
                'service': post.service,
                'date': post.date,
                'imageURL_1': post.image1,
                'imageURL_2': post.image2,
                'imageURL_3': post.image3,
                'imageURL_4': post.image4,
              }),
            );

            dev.log("Annonce restaurée (Undo)");
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'Aucun annonce ajouté pour le moment',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );

    if (_isLoading) {
      content = Center(child: CircularProgressIndicator());
    }

    if (_postListed.isNotEmpty) {
      content = ListView.builder(
        itemCount: _postListed.length,
        itemBuilder:
            (ctx, index) => Dismissible(
              background: Container(
                color: Theme.of(context).colorScheme.error,
                margin: EdgeInsets.symmetric(horizontal: 5),
              ),
              onDismissed: (direction) {
                _removePost(_postListed[index]);
              },
              key: ValueKey(_postListed[index].id),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                  elevation: 4,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest.withAlpha(120)
                          : Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _postListed[index].service,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit_note_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EditPostScreen(
                                          id: _postListed[index].id,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _postListed[index].description,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.4),
                          ),
                        ),

                        // Date
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Le ${_postListed[index].date}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                        // Images
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Photos associées:',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                separatorBuilder:
                                    (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, imgIndex) {
                                  final images = [
                                    _postListed[index].image1,
                                    _postListed[index].image2,
                                    _postListed[index].image3,
                                    _postListed[index].image4,
                                  ];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: ImageContainer(
                                      height: 65,
                                      width: 85,
                                      imageUrl: images[imgIndex],
                                      // placeholder: Icons.photo_library_outlined,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(
          _error!,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes annonces'),
        actions: [
          IconButton(onPressed: _addPost, icon: Icon(Icons.add, size: 35)),
        ],
      ),
      body: content,
    );
  }
}
