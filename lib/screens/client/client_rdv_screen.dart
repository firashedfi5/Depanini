import 'package:flutter/material.dart';

class ClientRdvScreen extends StatefulWidget {
  const ClientRdvScreen({super.key});

  @override
  State<ClientRdvScreen> createState() => _ClientRdvScreenState();
}

class _ClientRdvScreenState extends State<ClientRdvScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // 👈 Adjust length based on number of tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
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
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'À venir'),
                    Tab(text: 'Terminé'),
                    Tab(text: 'Annulé'),
                  ],
                ),
              ),
            ],
        body: TabBarView(
          controller: _tabController,
          children: [
            Center(
              child: Text(
                'Aucun réservation à venir',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            Center(
              child: Text(
                'Aucun réservation terminé',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            Center(
              child: Text(
                'Aucun réservation annulé',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
