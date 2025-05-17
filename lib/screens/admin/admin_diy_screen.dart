import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/astuce_model.dart';
import 'package:depanini/screens/admin/diy/edit_diy_screen.dart';
import 'package:depanini/screens/admin/diy/new_diy_screen.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class AdminDiyScreen extends StatefulWidget {
  const AdminDiyScreen({super.key});

  @override
  State<AdminDiyScreen> createState() => _AdminDiyScreenState();
}

class _AdminDiyScreenState extends State<AdminDiyScreen> {
  List<AstuceModel> _astuceListed = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAstuces();
  }

  void _loadAstuces() async {
    try {
      final snapshot =
          await _firestore
              .collection('astuces')
              .orderBy('createdAt', descending: true)
              .get();

      final List<AstuceModel> loadedAstuces =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return AstuceModel(
              id: doc.id,
              titre: data['titre'],
              description: data['description'],
              domaine: data['domaine'],
              foregroundImage: data['foreground_image'],
              createdAt: data['createdAt'],
            );
          }).toList();

      if (mounted) {
        setState(() {
          _astuceListed = loadedAstuces;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              'Echec de récupération des données. Veuillez réessayer plus tard.';
          _isLoading = false;
        });
      }
    }
  }

  void _addAstuce() async {
    await Navigator.of(context).push<AstuceModel>(
      MaterialPageRoute(builder: (context) => NewDiyScreen()),
    );
    _loadAstuces();
    dev.log("Astuce crée");
  }

  void _removeAstuce(AstuceModel astuce) async {
    final astuceIndex = _astuceListed.indexOf(astuce);
    final astuceRef = _firestore.collection('astuces').doc(astuce.id);

    // Remove from UI
    setState(() {
      _astuceListed.remove(astuce);
    });

    try {
      // Delete From Firestore
      await astuceRef.delete();
      dev.log("Astuce supprimée");

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
            content: const Text('Astuce supprimée'),
            action: SnackBarAction(
              label: 'Annuler',
              onPressed: () async {
                // Add back to UI
                setState(() {
                  _astuceListed.insert(astuceIndex, astuce);
                });

                // Restore in Firestore
                await _firestore.collection('astuces').doc(astuce.id).set({
                  'id': astuce.id,
                  'createdAt': astuce.createdAt,
                  'description': astuce.description,
                  'domaine': astuce.domaine,
                  'foreground_image': astuce.foregroundImage,
                  'titre': astuce.titre,
                });

                dev.log("Astuce restaurée (Undo)");
              },
            ),
          ),
        );
      }
    } catch (e) {
      dev.log("Erreur lors de la suppression: $e");
      // Revert UI change on error
      setState(() {
        _astuceListed.insert(astuceIndex, astuce);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(('Aucun astuce ajouté pour le moment')),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_astuceListed.isNotEmpty) {
      content = ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: _astuceListed.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final astuce = _astuceListed[index];

          return Dismissible(
            background: Container(
              color: Theme.of(context).colorScheme.error,
              margin: EdgeInsets.symmetric(horizontal: 5),
            ),
            onDismissed: (direction) {
              _removeAstuce(astuce);
            },
            key: ValueKey(astuce.id),
            child: Card(
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
                              color: Theme.of(context).colorScheme.onSecondary,
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
                    IconButton(
                      icon: Icon(
                        Icons.edit_note_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => EditDiyScreen(
                                  astuceId: astuce.id,
                                  originalDescription: astuce.description,
                                  originalTitle: astuce.titre,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
        title: const Text('Astuces de bricolage'),
        actions: [
          IconButton(
            onPressed: _addAstuce,
            icon: const Icon(Icons.add, size: 35),
          ),
        ],
      ),
      body: content,
    );
  }
}
