import 'package:anota_ai/pages/home_page.dart';
import 'package:anota_ai/provider/lista_itens_provider.dart';
import 'package:anota_ai/provider/usuario_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UsuarioProvider()),
        ChangeNotifierProvider(create: (context) => ListaItensProvider()),
      ],
      child: MaterialApp(
        title: 'Anota Aí',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 37, 73, 135)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 44, 56, 75),
            foregroundColor: Colors.white,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home:   HomePage(), //TODO alterar para ToggleLoginPage()
      ),
    );
  }
}
