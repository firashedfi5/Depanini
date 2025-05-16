import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Future<void> deleteAllNotificationsForCurrentUser() async {
    final uid = _auth.currentUser!.uid;

    final querySnapshot =
        await _firestore
            .collection('notifications')
            .where('récepteur_uid', isEqualTo: uid)
            .get();

    final batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Stream<List<NotificationModel>> notificationStream() {
    return _firestore
        .collection('notifications')
        .where('récepteur_uid', isEqualTo: _auth.currentUser!.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                return NotificationModel(
                  id: doc.id,
                  type: data['type'],
                  titre: data['titre'],
                  contenu: data['contenu'],
                  date: (data['date'] as Timestamp).toDate(),
                );
              }).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await deleteAllNotificationsForCurrentUser();
            },
            icon: Icon(Icons.delete),
            label: Text('Effacer tout'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: notificationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Aucune notification trouvée.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.separated(
            separatorBuilder: (_, _) => SizedBox(height: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              IconData icon;
              Color iconColor;

              switch (notification.type) {
                case 'rdv':
                  icon = Icons.calendar_today;
                  iconColor = Theme.of(context).colorScheme.primary;
                  break;
                case 'review':
                  icon = Icons.thumb_up_sharp;
                  iconColor = Colors.amber[600]!;
                  break;
                case 'annulation':
                  icon = Icons.cancel;
                  iconColor = Colors.red[600]!;
                  break;
                default:
                  icon = Icons.check_box;
                  iconColor = Colors.green[600]!;
              }

              return Dismissible(
                key: ValueKey(notification.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red.withValues(alpha: 0.1),
                  child: Icon(Icons.delete, color: Colors.red, size: 30),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notification.id)
                      .delete();
                },
                child: Card(
                  elevation: 2,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest.withAlpha(120)
                          : Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notification.titre,
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Icon(icon, color: iconColor),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          notification.contenu,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            timeago.format(notification.date, locale: 'fr'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
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
