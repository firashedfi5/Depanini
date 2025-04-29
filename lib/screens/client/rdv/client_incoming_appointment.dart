import 'package:flutter/material.dart';

class ClientIncomingAppointment extends StatefulWidget {
  const ClientIncomingAppointment({super.key});

  @override
  State<ClientIncomingAppointment> createState() =>
      _ClientIncomingAppointmentState();
}

class _ClientIncomingAppointmentState extends State<ClientIncomingAppointment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Builder(builder: (context) => CustomScrollView(
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        // final childCount = 25;

                        return SizedBox(
                          height: 50,
                          child: Card(
                            color: Colors.blueAccent,
                            child: Text('Item ${index + 1}'),
                          ),
                        );
                      }, childCount: 5),
                    ),
                  ),
                ],
              ) ,)
        ,
      ),
    );
  }
}
