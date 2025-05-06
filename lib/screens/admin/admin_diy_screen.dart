import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/astuce_model.dart';
import 'package:depanini/screens/admin/diy/new_diy_screen.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class AdminDiyScreen extends StatefulWidget {
  const AdminDiyScreen({super.key});

  @override
  State<AdminDiyScreen> createState() => _AdminDiyScreenState();
}

class _AdminDiyScreenState extends State<AdminDiyScreen> {
  Future<List<AstuceModel>> _loadAstuces() async {
    try {
      final snapshot = await _firestore.collection('astuces').get();

      final List<AstuceModel> loadedAstuces =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return AstuceModel(
              id: doc.id,
              titre: data['titre'],
              description: data['description'],
              domaine: data['domaine'],
              foregroundImage: data['foreground_image'],
            );
          }).toList();

      return loadedAstuces;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des astuces : $e');
    }
  }

  void _addPost() async {
    await Navigator.of(context).push<AstuceModel>(
      MaterialPageRoute(builder: (context) => NewDiyScreen()),
    );
    _loadAstuces();
    dev.log("Astuce crée");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Astuces de bricolage'),
        actions: [
          IconButton(onPressed: _addPost, icon: Icon(Icons.add, size: 35)),
        ],
      ),
      body: FutureBuilder(
        future: _loadAstuces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucun astuce ajouté pour le moment'),
            );
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final astuce = snapshot.data![index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withAlpha(120)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          astuce.foregroundImage ?? '',
                          width: 100,
                          height: 100,
                          fit: BoxFit.fitHeight,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade300,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                  size: 40,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              astuce.titre,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              astuce.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                astuce.domaine,
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
