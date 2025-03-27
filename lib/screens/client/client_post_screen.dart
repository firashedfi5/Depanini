import 'dart:convert';

// import 'package:depanini/screens/client/posts/edit_post_screen.dart';
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
  // ***********************************************

  void _addPost() async {
    await Navigator.of(
      context,
    ).push<PostModel>(MaterialPageRoute(builder: (context) => NewPostScreen()));
    _loadPosts();
    dev.log("Annonce crée");
  }

  void _removePost(PostModel post) {
    final url = Uri.http('10.0.2.2:3300', 'supprimer-annonces/${post.id}');
    http.delete(url);
    setState(() {
      _postListed.remove(post);
    });
    dev.log("Annonce supprimé");
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
              onDismissed: (direction) {
                _removePost(_postListed[index]);
              },
              key: ValueKey(_postListed[index].id),
              child: SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Card(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest
                            : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // IconButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder:
                        //             (context) => EditPostScreen(
                        //               id: _postListed[index].id,
                        //             ),
                        //       ),
                        //     );
                        //   },
                        //   icon: Icon(
                        //     Icons.edit_note_outlined,
                        //     color: Theme.of(context).colorScheme.primary,
                        //     size: 30,
                        //   ),
                        // ),
                        Text(_postListed[index].description),
                        Text(_postListed[index].service),
                        Text(
                          'Le ${_postListed[index].date}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ImageContainer(
                                height: 80,
                                width: 80,
                                imageUrl: _postListed[index].image1,
                              ),
                              SizedBox(width: 5),
                              ImageContainer(
                                height: 80,
                                width: 80,
                                imageUrl: _postListed[index].image2,
                              ),
                              SizedBox(width: 5),
                              ImageContainer(
                                height: 80,
                                width: 80,
                                imageUrl: _postListed[index].image3,
                              ),
                              SizedBox(width: 5),
                              ImageContainer(
                                height: 80,
                                width: 80,
                                imageUrl: _postListed[index].image4,
                              ),
                            ],
                          ),
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
        actions: [
          IconButton(onPressed: _addPost, icon: Icon(Icons.add, size: 35)),
        ],
      ),
      body: content,
    );
  }
}
