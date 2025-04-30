import 'package:depanini/screens/provider/rdv/provider_cancelled_appointment.dart';
import 'package:depanini/screens/provider/rdv/provider_completed_appointment.dart';
import 'package:depanini/screens/provider/rdv/provider_incoming_appointment.dart';
import 'package:depanini/screens/provider/rdv/provider_pending_appointment.dart';
import 'package:flutter/material.dart';

class ProviderRdvScreen extends StatefulWidget {
  const ProviderRdvScreen({super.key});

  @override
  State<ProviderRdvScreen> createState() => _ProviderRdvScreenState();
}

class _ProviderRdvScreenState extends State<ProviderRdvScreen> {
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
                      title: Text('Mes réservations'),
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
          body: TabBarView(
            children: [
              ProviderIncomingAppointment(),

              ProviderCompletedAppointment(),

              ProviderCancelledAppointment(),

              ProviderPendingAppointment(),
            ],
          ),
        ),
      ),
    );
  }
}
