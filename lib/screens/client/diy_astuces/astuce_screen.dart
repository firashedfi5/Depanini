import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/astuce_model.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class AstuceScreen extends StatelessWidget {
  // *************GET Method**********************
  Future<AstuceModel> _loadAstuce() async {
    try {
      final docSnapshot = await _firestore.collection('astuces').doc(id).get();

      if (!docSnapshot.exists) {
        throw Exception('Aucune astuce trouvée.');
      }

      final data = docSnapshot.data()!;

      return AstuceModel(
        id: id,
        titre: data["titre"] ?? "Titre inconnu",
        description: data["description"] ?? "Description non disponible",
        domaine: data["domaine"] ?? "Domaine non spécifié",
        foregroundImage: data["foreground_image"],
      );
    } catch (e) {
      throw Exception('Erreur de récupération de l\'astuce : $e');
    }
  }

  // *************GET Method**********************

  final String id;
  final String titre;
  const AstuceScreen({super.key, required this.id, required this.titre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: FutureBuilder(
        future: _loadAstuce(),
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
          return Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Domaine Section
                Text(
                  'Domaine',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  snapshot.data!.domaine,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Description Section
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  snapshot.data!.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // DIY Pictures Section
                Text(
                  'Étapes de bricolage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withAlpha(70),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: 4, // Replace with actual image count
                    itemBuilder: (context, index) {
                      return Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest.withAlpha(100),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 32,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Step ${index + 1}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
