import 'package:depanini/screens/client/rdv/client_rdv_a_venir.dart';
import 'package:depanini/screens/client/rdv/client_rdv_annule.dart';
import 'package:depanini/screens/client/rdv/client_rdv_en_attente.dart';
import 'package:depanini/screens/client/rdv/client_rdv_termine.dart';
import 'package:flutter/material.dart';

class ClientRdvScreen extends StatefulWidget {
  const ClientRdvScreen({super.key});

  @override
  State<ClientRdvScreen> createState() => _ClientRdvScreenState();
}

class _ClientRdvScreenState extends State<ClientRdvScreen> {
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
              ClientRdvAVenir(),

              ClientRdvTermine(),

              ClientRdvAnnule(),

              ClientRdvEnAttente(),
            ],
          ),
        ),
      ),
    );
  }
}
