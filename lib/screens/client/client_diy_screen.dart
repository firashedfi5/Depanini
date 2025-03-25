import 'package:flutter/material.dart';

class ClientDiyScreen extends StatefulWidget {
  const ClientDiyScreen({super.key});

  @override
  State<ClientDiyScreen> createState() => _ClientDiyScreenState();
}

class _ClientDiyScreenState extends State<ClientDiyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.tune)),
          ),
        ],
        title: SizedBox(
          height: 40,
          width: 350,
          child: SearchBar(
            leading: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.primary,
            ),
            hintText: 'Rechercher...',
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context).brightness == Brightness.dark
                  ? Color.fromARGB(255, 43, 43, 49) // Dark theme color
                  : const Color.fromARGB(255, 236, 229, 243),
            ),
          ),
        ),
      ),
      body: Center(child: Text('DIY Screen', style: TextStyle(fontSize: 35))),
    );
  }
}
