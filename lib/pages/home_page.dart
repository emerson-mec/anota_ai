import 'package:anota_ai/widget/drawer_custom.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tela Inicial'),
          actions: [
            IconButton(
              tooltip: '',
              icon: const Icon(Icons.stacked_bar_chart),
              onPressed: () {
              },
            ),
          ],
        ),
        drawer: DrawerCUSTOM(),
        body: Center(
          child: const Text(
            'Bem-vindo ao Anota AI!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
