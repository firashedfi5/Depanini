import 'package:depanini/screens/client/new_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:depanini/models/post_model.dart';

class ClientPostScreen extends StatefulWidget {
  const ClientPostScreen({super.key});

  @override
  State<ClientPostScreen> createState() => _ClientPostScreenState();
}

class _ClientPostScreenState extends State<ClientPostScreen> {
  final List<PostModel> _postListed = [];
  void _addPost() async {
    final newPost = await Navigator.of(
      context,
    ).push<PostModel>(MaterialPageRoute(builder: (context) => NewPostScreen()));
    if (newPost == null) {
      return;
    }
    setState(() {
      _postListed.add(newPost);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _addPost, icon: Icon(Icons.add, size: 35)),
        ],
      ),
      body: ListView.builder(
        itemCount: _postListed.length,
        itemBuilder:
            (ctx, index) => SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(_postListed[index].uid),
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
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                            _postListed[index].image1!,
                                          ),
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
                                          Theme.of(context).colorScheme.primary,
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
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                            _postListed[index].image2!,
                                          ),
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
                                          Theme.of(context).colorScheme.primary,
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
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                            _postListed[index].image3!,
                                          ),
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
                                          Theme.of(context).colorScheme.primary,
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
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                            _postListed[index].image4!,
                                          ),
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
                                          Theme.of(context).colorScheme.primary,
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
}
