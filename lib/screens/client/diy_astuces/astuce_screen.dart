import 'dart:convert';

import 'package:depanini/models/astuce_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AstuceScreen extends StatelessWidget {
  // *************GET Method**********************
  Future<AstuceModel> _loadAnnonce() async {
    final url = Uri.http('10.0.2.2:3300', 'afficher-astuce/$id');
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

    return AstuceModel(
      id: data["id"],
      titre: data["titre"] ?? "Titre inconnu",
      description: data["description"] ?? "Description non disponible",
      domaine: data["domaine"] ?? "Domaine non spécifié",
    );
  }

  // *************GET Method**********************

  final int id;
  final String titre;
  const AstuceScreen({super.key, required this.id, required this.titre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titre)),
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
                Text(
                  'Domaine: ${snapshot.data!.domaine}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 10),
                Text('Description: ${snapshot.data!.description}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
