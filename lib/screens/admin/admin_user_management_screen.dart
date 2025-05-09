import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/models/client_account_model.dart';
import 'package:depanini/models/unified_model.dart';
import 'package:depanini/screens/admin/user%20management/client_info_screen.dart';
import 'package:depanini/screens/admin/user%20management/prestataire_info_screen.dart';
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
  int? usersCount;
  Future<List<UnifiedUser>> _foundedUsers = Future.value([]);

  @override
  void initState() {
    super.initState();
    _foundedUsers = getAllUsers();
  }

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

  void searchUsers(String search) {
    String searchLower = search.toLowerCase().trim();

    getAllUsers().then((users) {
      final filtered =
          searchLower.isEmpty
              ? users
              : users.where((user) {
                final username = user.username.toLowerCase();
                final email = user.email.toLowerCase();
                final phone = user.phoneNumber.toLowerCase();

                return username.contains(searchLower) ||
                    email.contains(searchLower) ||
                    phone.contains(searchLower);
              }).toList();

      setState(() {
        _foundedUsers = Future.value(filtered);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 110,
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gestion des utilisateurs'),
                    const SizedBox(height: 4),
                    FutureBuilder<List<UnifiedUser>>(
                      future: getAllUsers(),
                      builder: (context, snapshot) {
                        final count =
                            snapshot.hasData ? snapshot.data!.length : 0;
                        return Text.rich(
                          TextSpan(
                            text: 'Nombre total d\'utilisateurs: ',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: count.toString(),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 40,
                      width: 370,
                      child: SearchBar(
                        onChanged: searchUsers,
                        onSubmitted: searchUsers,
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
        body: FutureBuilder<List<UnifiedUser>>(
          future: _foundedUsers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun utilisateur trouvé.'));
            }

            final users = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  final profilPicture =
                      user.type == UserType.client
                          ? user.clientData?.profilPicture
                          : user.providerData?.profilPicture;

                  final username =
                      user.type == UserType.client
                          ? user.clientData?.username ?? 'Nom inconnu'
                          : user.providerData?.username ?? 'Nom inconnu';

                  final email =
                      user.type == UserType.client
                          ? user.clientData?.email ?? 'Nom inconnu'
                          : user.providerData?.email ?? 'Nom inconnu';

                  final role =
                      user.type == UserType.client ? "Client" : "Prestataire";

                  return InkWell(
                    onTap: () {
                      if (user.type == UserType.client) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ClientInfoScreen(
                                  clientData: user.clientData!,
                                ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PrestataireInfoScreen(
                                  providerData: user.providerData!,
                                ),
                          ),
                        );
                      }
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withAlpha(120)
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Profile Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                profilPicture!,
                                fit: BoxFit.cover,
                                scale: 1.75,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.person, size: 48),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Info Section
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    role,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  email,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),

                                // // Rating
                              ],
                            ),
                            Spacer(),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Activé',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
