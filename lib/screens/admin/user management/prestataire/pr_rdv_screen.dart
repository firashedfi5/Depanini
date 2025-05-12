import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/place.dart';
import 'package:depanini/models/rdv_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;

class PrRdvScreen extends StatefulWidget {
  final String uid;
  final String username;

  const PrRdvScreen({super.key, required this.uid, required this.username});

  @override
  State<PrRdvScreen> createState() => _PrRdvScreenState();
}

class _PrRdvScreenState extends State<PrRdvScreen> {
  Color getStatusColor(String status) {
    switch (status) {
      case 'completé':
        return Colors.blue;
      case 'en_attente':
        return Colors.orange;
      case 'confirmé':
        return Colors.green;
      case 'annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'completé':
        return 'Completé';
      case 'en_attente':
        return 'En attente';
      case 'confirmé':
        return 'Confirmé';
      case 'annulé':
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  Future<List<RdvModel>> getRdv() async {
    try {
      final snapshot =
          await _firestore
              .collection('rdvs')
              .orderBy('date', descending: false)
              .where('prestataire_uid', isEqualTo: widget.uid)
              .get();

      final List<RdvModel> loadedAstuces =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return RdvModel(
              id: doc.id,
              clientUid: data['client_uid'],
              clientUsername: data['client_username'],
              clientProfilePicture: data['client_profile_picture'],
              clientLocation: PlaceLocation(
                latitude: data['client_Lat&Long'].latitude,
                longitude: data['client_Lat&Long'].longitude,
                address: data['client_location'],
              ),
              prestataireLocation: PlaceLocation(
                latitude: data['prestataire_Lat&Long'].latitude,
                longitude: data['prestataire_Lat&Long'].longitude,
                address: data['prestataire_location'],
              ),
              prestataireUid: data['prestataire_uid'],
              prestataireUsername: data['prestataire_username'],
              prestataireProfilePicture: data['prestataire_profile_picture'],
              service: data['service'],
              date: (data['date'] as Timestamp).toDate(),
              heure: data['heure'],
              status: data['status'],
            );
          }).toList();

      return loadedAstuces;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des astuces : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rendez-vous de ${widget.username}')),
      body: FutureBuilder(
        future: getRdv(),
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

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Aucun rendez-vous trouvé',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          final List<RdvModel> rdvs = snapshot.data as List<RdvModel>;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: rdvs.length,
            itemBuilder: (context, index) {
              final rdv = rdvs[index];
              final statusColor = getStatusColor(rdv.status);
              final statusLabel = getStatusLabel(rdv.status);
              return Card(
                elevation: 2,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withAlpha(100)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage:
                                rdv.clientProfilePicture.isNotEmpty
                                    ? NetworkImage(rdv.clientProfilePicture)
                                    : null,
                            child:
                                rdv.clientProfilePicture.isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rdv.clientUsername,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                rdv.service,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(50),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              statusLabel,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium!.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_today,
                            text: DateFormat('dd/MM/yyyy').format(rdv.date),
                          ),
                          const SizedBox(width: 30),
                          _InfoChip(icon: Icons.access_time, text: rdv.heure),
                        ],
                      ),
                      const SizedBox(height: 12),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
