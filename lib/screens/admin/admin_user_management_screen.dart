import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/models/client_account_model.dart';
import 'package:depanini/models/unified_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  Future<List<UnifiedUser>> getAllUsers() async {
    final clientsSnap = await _firestore.collection("clients").get();
    final prestatairesSnap = await _firestore.collection("prestataires").get();

    final clients = clientsSnap.docs.map((doc) {
      return UnifiedUser(
        id: doc.id,
        type: UserType.client,
        clientData: ClientModel.fromSnapshot(doc),
      );
    });

    final prestataires = prestatairesSnap.docs.map((doc) {
      return UnifiedUser(
        id: doc.id,
        type: UserType.prestataire,
        providerData: ProviderAccountModel.fromSnapshot(doc),
      );
    });

    return [...clients, ...prestataires];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                title: Text('Gestion des utilisateurs'),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(50),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 40,
                      width: 370,
                      child: SearchBar(
                        leading: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        hintText: 'Rechercher un utilisateur',
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(
                                context,
                              ).colorScheme.onSecondaryFixedVariant
                              : const Color.fromARGB(255, 228, 216, 240),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: FutureBuilder<List<UnifiedUser>>(
            future: getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Aucun utilisateur trouvé.'));
              }

              final users = snapshot.data!;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  final String name =
                      user.type == UserType.client
                          ? user.clientData?.username ?? 'Nom inconnu'
                          : user.providerData?.username ?? 'Nom inconnu';

                  final String email =
                      user.type == UserType.client
                          ? user.clientData?.email ?? 'Nom inconnu'
                          : user.providerData?.email ?? 'Nom inconnu';

                  final String phoneNumber =
                      user.type == UserType.client
                          ? user.clientData?.phoneNumber ?? 'Nom inconnu'
                          : user.providerData?.phoneNumber ?? 'Nom inconnu';

                  final String address =
                      user.type == UserType.client
                          ? user.clientData?.localisation ?? 'Nom inconnu'
                          : user.providerData?.localisation ?? 'Nom inconnu';

                  final String roleText =
                      user.type == UserType.client ? "Client" : "Prestataire";

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest.withAlpha(120)
                            : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name),
                          Text(roleText),
                          Text(email),
                          Text(phoneNumber),
                          Text(address),
                        ],
                      ),
                    ),
                    // ListTile(
                    //   title: Text(name),
                    //   subtitle: Text(roleText),
                    // ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
