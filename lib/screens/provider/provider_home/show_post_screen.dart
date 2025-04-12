import 'dart:convert';

import 'package:depanini/models/post_model.dart';
import 'package:depanini/screens/common/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  final int id;
  const ShowPostScreen({super.key, required this.id});

  Future<PostModel> _loadAnnonce() async {
    final url = Uri.http(
      '192.168.1.11:3300',
      'afficher-seule-annonces/$id',
    ); // Virtual Device: 10.0.2.2 - Actual Device: 192.168.1.11 (ipconfig -> IPv4)
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception(
        'Échec de récupération des données. Veuillez réessayer plus tard.',
      );
    }

    // Decode the JSON response
    final List<dynamic> listData = json.decode(response.body);

    // Ensure the list is not empty before accessing the first element
    if (listData.isEmpty) {
      throw Exception('Aucune astuce trouvée.');
    }

    // Extract the first object from the list
    final Map<String, dynamic> data = listData[0];

    return PostModel(
      id: data["id"],
      email: data["email"],
      uid: data["uid"],
      username: data["username"],
      phoneNumber: data["phone_number"],
      profilPicture: data["profil_picture"],
      description: data["description"],
      service: data['service'],
      date: data['date'],
    );
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
                                              username: snapshot.data!.username,
                                              profilPictureUrl:
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
