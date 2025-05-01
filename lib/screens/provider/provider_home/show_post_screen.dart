import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/post_model.dart';
import 'package:depanini/screens/common/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final _firestore = FirebaseFirestore.instance;

class ShowPostScreen extends StatelessWidget {
  // *********Phone Call*****************
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not make the phone call';
    }
  }

  // *********Phone Call*****************
  final String id;
  const ShowPostScreen({super.key, required this.id});

  Future<PostModel> _loadAnnonce() async {
    try {
      final doc = await _firestore.collection('annonces').doc(id).get();

      if (!doc.exists) {
        throw Exception('Aucune annonce trouvée.');
      }

      final data = doc.data()!;

      return PostModel(
        id: doc.id,
        email: data["email"],
        uid: data["uid"],
        username: data["username"],
        phoneNumber: data["phone_number"],
        profilPicture: data["profil_picture"],
        description: data["description"],
        service: data['service'],
        date: data['date'],
        createdAt: data['createdAt'],
        image1: data["imageURL_1"],
        image2: data["imageURL_2"],
        image3: data["imageURL_3"],
        image4: data["imageURL_4"],
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'annonce : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Description d\'annonce')),
      body: FutureBuilder(
        future: _loadAnnonce(),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest.withAlpha(100)
                          : Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.data!.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            // Domaine Info
                            Row(
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Domaine',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                    ),
                                    Text(
                                      snapshot.data!.service,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            // Date Info
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                    ),
                                    Text(
                                      snapshot.data!.date,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest.withAlpha(100)
                          : Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                  elevation: 2,
                  child: SizedBox(
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              snapshot.data!.profilPicture,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  snapshot.data!.username,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  snapshot.data!.phoneNumber,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton.filled(
                                icon: Icon(
                                  Icons.call,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                onPressed:
                                    () => _makePhoneCall(
                                      '+216${snapshot.data!.phoneNumber}',
                                    ),
                                style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              IconButton.filled(
                                icon: Icon(
                                  Icons.message,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ChatScreen(
                                              receiverEmail:
                                                  snapshot.data!.email,
                                              receiverUsername:
                                                  snapshot.data!.username,
                                              receiverProfilPicture:
                                                  snapshot.data!.profilPicture,
                                            ),
                                      ),
                                    ),
                                style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
