import 'package:depanini/screens/prestataire/rdv/prestataire_rdv_a_venir.dart';
import 'package:depanini/screens/prestataire/rdv/prestataire_rdv_annule.dart';
import 'package:depanini/screens/prestataire/rdv/prestataire_rdv_en_attente.dart';
import 'package:depanini/screens/prestataire/rdv/prestataire_rdv_termine.dart';
import 'package:flutter/material.dart';

class PrestataireRdvScreen extends StatefulWidget {
  const PrestataireRdvScreen({super.key});

  @override
  State<PrestataireRdvScreen> createState() => _PrestataireRdvScreenState();
}

class _PrestataireRdvScreenState extends State<PrestataireRdvScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: const SliverSafeArea(
                    top: false,
                    sliver: SliverAppBar(
                      title: Text('Mes rendez-vous'),
                      pinned: true,
                      floating: true,
                      bottom: TabBar(
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        // indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: 'À venir'),
                          Tab(text: 'Terminé'),
                          Tab(text: 'Annulé'),
                          Tab(text: 'En attente'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
          body: const TabBarView(
            children: [
              PrestataireRdvAVenir(),

              PrestataireRdvTermine(),

              PrestataireRdvAnnule(),

              PrestataireRdvEnAttente(),
            ],
          ),
        ),
      ),
    );
  }
}
