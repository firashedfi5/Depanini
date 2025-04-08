import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/screens/common/chat_screen.dart';
import 'package:depanini/widgets/image_container.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProviderInfoScreen extends StatelessWidget {
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

  Future<ProviderAccountModel> getUserData() async {
    final data =
        await _firestore
            .collection("prestataires")
            .where("Email", isEqualTo: email)
            .get();
    final snapshot =
        data.docs.map((doc) => ProviderAccountModel.fromSnapshot(doc)).single;
    return snapshot;
  }

  const ProviderInfoScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prestataire description')),
      body: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    snapshot.data!.profilPicture,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  snapshot.data!.username,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  snapshot.data!.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  snapshot.data!.diplome,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  snapshot.data!.experience,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      child: ElevatedButton(
                        onPressed: () {
                          _makePhoneCall('+216${snapshot.data!.phoneNumber}');
                        },
                        child: Icon(Icons.call),
                      ),
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 70,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(),
                            ),
                          );
                        },
                        child: Icon(Icons.message),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  child: Row(
                    children: [
                      ImageContainer(
                        height: 90,
                        width: 90,
                        imageUrl: snapshot.data!.workPicture_1,
                      ),
                      SizedBox(width: 10),
                      ImageContainer(
                        height: 90,
                        width: 90,
                        imageUrl: snapshot.data!.workPicture_2,
                      ),
                      SizedBox(width: 10),
                      ImageContainer(
                        height: 90,
                        width: 90,
                        imageUrl: snapshot.data!.workPicture_3,
                      ),
                      SizedBox(width: 10),
                      ImageContainer(
                        height: 90,
                        width: 90,
                        imageUrl: snapshot.data!.workPicture_4,
                      ),
                    ],
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
