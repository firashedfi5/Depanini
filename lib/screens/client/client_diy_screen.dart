import 'dart:convert';

import 'package:depanini/constants/domains.dart';
import 'package:depanini/data/word_to_field.dart';
import 'package:depanini/models/astuce_model.dart';
import 'package:depanini/screens/client/diy_astuces/astuce_screen.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

class ClientDiyScreen extends StatefulWidget {
  const ClientDiyScreen({super.key});

  @override
  State<ClientDiyScreen> createState() => _ClientDiyScreenState();
}

class _ClientDiyScreenState extends State<ClientDiyScreen> {
  final List<Domains> _domains = Domains.values;
  String? _selectedDomain;

  bool isSelected = false;

  Future<List<AstuceModel>> _foundedAstuces = Future.value([]);

  @override
  void initState() {
    super.initState();
    _foundedAstuces = _loadAstcues();
  }

  // *************GET Method**********************
  Future<List<AstuceModel>> _loadAstcues() async {
    final url = Uri.http(
      '192.168.1.11:3300',
      'afficher-astuces',
    ); // Virtual Device: 10.0.2.2 - Actual Device: 192.168.1.11 (ipconfig -> IPv4)
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception(
        'Echec de récupération des données. Veuillez réessayer plus tard.',
      );
    }

    // Decode the JSON response correctly as a List
    final List<dynamic> listData = json.decode(response.body);

    final List<AstuceModel> loadedAstuces =
        listData.map((astuce) {
          return AstuceModel(
            id: astuce["id"],
            titre: astuce["titre"],
            description: astuce["description"],
            domaine: astuce["domaine"],
            foregroundImage: astuce["foreground_image"],
          );
        }).toList();

    return loadedAstuces;
  }
  // *************GET Method**********************

  // ***********Search************************
  void searchAstuces(String search) {
    String searchLower = search.toLowerCase().trim();

    // If search input is empty, return all users
    if (searchLower.isEmpty) {
      _loadAstcues().then((astuces) {
        setState(() {
          _foundedAstuces = Future.value(astuces);
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

    _loadAstcues().then((astuce) {
      setState(() {
        _foundedAstuces = Future.value(
          astuce.where((astuce) {
            return astuce.domaine.toLowerCase().contains(mappedField);
          }).toList(),
        );
      });
    });
  }

  // ***********Search************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                toolbarHeight: 60,
                // pinned: true,
                floating: true,
                snap: true,
                title: SizedBox(
                  height: 35,
                  // width: 350,
                  child: SearchBar(
                    onChanged: (value) {
                      searchAstuces(value);
                    },
                    onSubmitted: (value) {
                      searchAstuces(value);
                    },
                    leading: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    hintText: 'Salut, de quoi as-tu besoin d\'aide ?',
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).brightness == Brightness.dark
                          ? Color.fromARGB(255, 43, 43, 49) // Dark theme color
                          : const Color.fromARGB(255, 236, 229, 243),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(50),
                  child: SizedBox(
                    height: 50,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (_, __) => SizedBox(width: 10),
                      itemCount: _domains.length,
                      itemBuilder: (context, index) {
                        return FilterChip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Rounded edges
                          ),
                          avatar: _domains[index].icon,
                          showCheckmark: false,
                          selectedColor:
                              Theme.of(context).colorScheme.secondary,
                          label: Text(_domains[index].name),
                          selected: _selectedDomain == _domains[index].name,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                _selectedDomain = _domains[index].name;
                              } else {
                                _selectedDomain = null;
                              }
                            });
                            searchAstuces(value ? _domains[index].name : '');
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
        body: FutureBuilder(
          future: _foundedAstuces,
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
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Aucun astuce ajouté pour le moment'),
              );
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AstuceScreen(
                              id: snapshot.data![index].id,
                              titre: snapshot.data![index].titre,
                            ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest.withAlpha(120)
                            : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(7.5),
                      child: Column(
                        children: [
                          // Image Container
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                snapshot.data![index].foregroundImage!,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) => Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                        size: 40,
                                      ),
                                    ),
                              ),
                            ),
                          ),

                          // Text Content
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Title
                                Text(
                                  snapshot.data![index].titre,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),

                                // Domaine Chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    snapshot.data![index].domaine,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium!.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
