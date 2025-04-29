import 'package:flutter/material.dart';

class ClientCancelledAppointment extends StatefulWidget {
  const ClientCancelledAppointment({super.key});

  @override
  State<ClientCancelledAppointment> createState() =>
      _ClientCancelledAppointmentState();
}

class _ClientCancelledAppointmentState
    extends State<ClientCancelledAppointment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder:
              (context) => CustomScrollView(
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withAlpha(120)
                                : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                            child: Text('Item ${index + 1}'),
                          ),
                        );
                      }, childCount: 20),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
