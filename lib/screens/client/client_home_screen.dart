import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/constants/domains.dart';
import 'package:depanini/models/place.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/screens/client/home/provider_info_screen.dart';
import 'package:depanini/screens/common/map.dart';
import 'package:depanini/screens/common/notifications_screen.dart';
// import 'package:depanini/screens/common/onboarding_screen.dart';
import 'package:depanini/widgets/custom_radio_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:depanini/data/word_to_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Domains> _domains = Domains.values;
  int selected = -1;

  Future<List<ProviderAccountModel>> _foundedUsers = Future.value([]);

  Future<List<ProviderAccountModel>> getAllData() async {
    final data =
        await _firestore
            .collection("prestataires")
            .orderBy("averageRating", descending: true)
            .get();
    final snapshot =
        data.docs.map((doc) => ProviderAccountModel.fromSnapshot(doc)).toList();
    return snapshot;
  }

  late Stream<DocumentSnapshot> userStream;
  final user = _auth.currentUser!;

  @override
  void initState() {
    super.initState();
    userStream = _firestore.collection("clients").doc(user.uid).snapshots();
    _foundedUsers = getAllData();
  }

  // ***********Search************************
  void searchUsers(String search) {
    String searchLower = search.toLowerCase().trim();

    // If search input is empty, return all users
    if (searchLower.isEmpty) {
      getAllData().then((users) {
        setState(() {
          _foundedUsers = Future.value(users);
        });
      });
      return;
    }

    // Check if the search term matches part of any keyword in the map
    String mappedField = '';
    wordToField.forEach((key, value) {
      if (key.contains(searchLower)) {
        mappedField = value;
      }
    });

    // If no match is found in the map, use the original search term
    mappedField = mappedField.isEmpty ? searchLower : mappedField;

    getAllData().then((users) {
      setState(() {
        _foundedUsers = Future.value(
          users.where((user) {
            return user.domaine.toLowerCase().contains(mappedField) ||
                user.username.toLowerCase().contains(mappedField);
          }).toList(),
        );
      });
    });
  }

  // ***********Search************************

  // **********Prestataires Localisation*************
  List<PlaceLocation> extractPrestataireLocations(
    List<ProviderAccountModel> providers,
  ) {
    return providers.map((provider) {
      return PlaceLocation(
        address: provider.localisation,
        latitude: provider.latitude,
        longitude: provider.longitude,
      );
    }).toList();
  }

  // **********Prestataires Localisation*************

  Stream<int> _notificationCountStream() {
    return _firestore
        .collection('notifications')
        .where('récepteur_uid', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                // snap: true,
                expandedHeight: 200,
                title: StreamBuilder<DocumentSnapshot>(
                  stream: userStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text("Aucune donnée trouvée"));
                    }

                    // Extract user data from DocumentSnapshot
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;

                    return Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              foregroundImage:
                                  userData['Photo de profile'] != null
                                      ? CachedNetworkImageProvider(
                                        userData['Photo de profile'],
                                        cacheKey: userData['Photo de profile'],
                                      )
                                      : null,
                              child:
                                  userData['Photo de profile'] == null
                                      ? const Icon(
                                        Icons.person,
                                        size: 70,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () async {
                                final prestataires =
                                    await _foundedUsers; // Await the current list
                                final prestataireLocations =
                                    extractPrestataireLocations(prestataires);

                                if (!context.mounted) return;

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MapScreen(
                                          location: PlaceLocation(
                                            address: userData['Localisation'],
                                            latitude:
                                                userData['Latitude&Longitude']
                                                    .latitude,
                                            longitude:
                                                userData['Latitude&Longitude']
                                                    .longitude,
                                          ),
                                          isSelecting: false,
                                          othersLocations: prestataireLocations,
                                          prestataireInfo: prestataires,
                                        ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: 'Salut, ', // Normal text
                                      style:
                                          Theme.of(context)
                                              .textTheme
                                              .titleMedium, // Default style
                                      children: [
                                        TextSpan(
                                          text:
                                              userData['Nom d\'utilisateur'], // Bold text
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.pin_drop_outlined,
                                        size: 17,
                                      ),
                                      const SizedBox(width: 3),
                                      SizedBox(
                                        width: 230,
                                        child: Text(
                                          userData['Localisation'],
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const NotificationsScreen(),
                                  ),
                                );
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder:
                                //         (context) => const OnboardingScreen(),
                                //   ),
                                // );
                              },
                              icon: SizedBox(
                                width: 30,
                                height: 30,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(Icons.notifications, size: 30),
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: StreamBuilder<int>(
                                        stream: _notificationCountStream(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const SizedBox(); // or a subtle shimmer/dot
                                          }

                                          if (snapshot.hasError) {
                                            return const SizedBox(); // or an error indicator
                                          }

                                          final count = snapshot.data ?? 0;

                                          if (count == 0) {
                                            return const SizedBox();
                                          }

                                          return Container(
                                            padding: const EdgeInsets.all(2),
                                            constraints: const BoxConstraints(
                                              minWidth: 15,
                                              minHeight: 15,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Color(0xffc32c37),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                count > 99
                                                    ? '99+'
                                                    : count.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(125),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 35,
                        width: 360,
                        child: SearchBar(
                          leading: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onChanged: (value) {
                            searchUsers(value);
                          },
                          onSubmitted: (value) {
                            searchUsers(value);
                          },
                          hintText: 'Que faut-il réparer ?',
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSecondaryFixedVariant
                                : const Color.fromARGB(255, 228, 216, 240),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 74,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: _domains.length,
                          itemBuilder: (context, index) {
                            return CustomRadioButton(
                              borderSide: false,
                              label: _domains[index].name,
                              index: index,
                              image: _domains[index].image,
                              selectedIndex: selected,
                              onPressed: () {
                                setState(() {
                                  if (selected == index) {
                                    selected = -1;
                                    searchUsers('');
                                  } else {
                                    selected = index;
                                    searchUsers(_domains[index].name);
                                  }
                                  dev.log(selected.toString());
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
        body: FutureBuilder<List<ProviderAccountModel>>(
          future: _foundedUsers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Aucun prestataire ajouté pour le moment'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProviderInfoScreen(
                              uid: snapshot.data![index].uid,
                              email: snapshot.data![index].email,
                            ),
                      ),
                    );
                    // Reload data when returning
                    if (mounted) {
                      setState(() {
                        _foundedUsers = getAllData(); // <-- Trigger rebuild
                      });
                    }
                  },
                  child: Container(
                    height: 135,
                    margin: const EdgeInsets.symmetric(vertical: 5),
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
                            Container(
                              width: 100,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade200,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  key: ValueKey(
                                    snapshot.data![index].profilPicture,
                                  ),
                                  imageUrl: snapshot.data![index].profilPicture,
                                  placeholder:
                                      (context, url) => const SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: CircularProgressIndicator(),
                                      ),
                                  errorWidget:
                                      (context, url, error) => const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Info Section
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data![index].username,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      snapshot.data![index].domaine,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Rating
                                  Row(
                                    children: [
                                      RatingBarIndicator(
                                        rating:
                                            snapshot.data![index].averageRating,
                                        itemBuilder:
                                            (context, index) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                        itemCount: 5,
                                        itemSize: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        snapshot.data![index].averageRating
                                            .toStringAsFixed(2),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
