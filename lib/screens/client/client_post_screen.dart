import 'dart:convert';

import 'package:depanini/screens/client/new_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:depanini/models/post_model.dart';

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
      // print(response.statusCode);

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
      setState(() {
        _error =
            'Echec de récupération des données. Veuillez réessayer plus tard.';
      });
    }
  }
  // ***********************************************

  void _addPost() async {
    await Navigator.of(
      context,
    ).push<PostModel>(MaterialPageRoute(builder: (context) => NewPostScreen()));
    _loadPosts();
    print("Annonce crée");
  }

  void _removePost(PostModel post) {
    final url = Uri.http('10.0.2.2:3300', 'supprimer-annonces/${post.id}');
    http.delete(url);
    setState(() {
      _postListed.remove(post);
    });
    print("Annonce supprimé");
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Annonce num: ${_postListed[index].id}"),
                        Text(_postListed[index].description),
                        Text(_postListed[index].service),
                        Text(_postListed[index].date),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHigh,
                                  image:
                                      _postListed[index].image1 != null
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              _postListed[index].image1!,
                                            ),
                                            fit:
                                                BoxFit
                                                    .cover, // Optional: Adjusts the image fit
                                          )
                                          : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_postListed[index].image1 == null)
                                      Icon(
                                        Icons.no_photography_outlined,
                                        size: 30,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHigh,
                                  image:
                                      _postListed[index].image2 != null
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              _postListed[index].image2!,
                                            ),
                                            fit:
                                                BoxFit
                                                    .cover, // Optional: Adjusts the image fit
                                          )
                                          : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_postListed[index].image2 == null)
                                      Icon(
                                        Icons.no_photography_outlined,
                                        size: 30,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHigh,
                                  image:
                                      _postListed[index].image3 != null
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              _postListed[index].image3!,
                                            ),
                                            fit:
                                                BoxFit
                                                    .cover, // Optional: Adjusts the image fit
                                          )
                                          : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_postListed[index].image3 == null)
                                      Icon(
                                        Icons.no_photography_outlined,
                                        size: 30,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHigh,
                                  image:
                                      _postListed[index].image4 != null
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              _postListed[index].image4!,
                                            ),
                                            fit:
                                                BoxFit
                                                    .cover, // Optional: Adjusts the image fit
                                          )
                                          : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_postListed[index].image4 == null)
                                      Icon(
                                        Icons.no_photography_outlined,
                                        size: 30,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
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
