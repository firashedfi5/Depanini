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
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text('Description: ${snapshot.data!.description}'),
                Text('Domaine: ${snapshot.data!.service}'),
                Text('Date: ${snapshot.data!.date}'),
                Text('Date: ${snapshot.data!.phoneNumber}'),
                SizedBox(
                  height: 85,
                  child: Card(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest
                            : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    child: Row(
                      children: [
                        Image.network(snapshot.data!.profilPicture),
                        Text(
                          snapshot.data!.username,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Spacer(),
                        SizedBox(
                          width: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _makePhoneCall(
                                '+216${snapshot.data!.phoneNumber}',
                              );
                            },
                            child: Icon(Icons.call, size: 25),
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatScreen(
                                        username: snapshot.data!.username,
                                        profilPictureUrl:
                                            snapshot.data!.profilPicture,
                                      ),
                                ),
                              );
                            },
                            child: Icon(Icons.message),
                          ),
                        ),
                      ],
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
