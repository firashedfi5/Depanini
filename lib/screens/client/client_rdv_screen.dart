import 'package:depanini/screens/client/rdv/client_cancelled_appointment.dart';
import 'package:depanini/screens/client/rdv/client_completed_appointment.dart';
import 'package:depanini/screens/client/rdv/client_incoming_appointment.dart';
import 'package:depanini/screens/client/rdv/client_pending_appointment.dart';
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
                  sliver: SliverSafeArea(
                    top: false,
                    sliver: SliverAppBar(
                      title: const Text('Mes réservations'),
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
                          const Tab(text: 'À venir'),
                          const Tab(text: 'Terminé'),
                          const Tab(text: 'Annulé'),
                          const Tab(text: 'En attente'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
          body: TabBarView(
            children: [
              ClientIncomingAppointment(),

              ClientCompletedAppointment(),

              ClientCancelledAppointment(),

              ClientPendingAppointment(),
            ],
          ),
        ),
      ),
    );
  }
}
