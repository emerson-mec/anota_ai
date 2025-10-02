import 'package:anota_ai/firebase_options.dart';
import 'package:anota_ai/provider/lista_itens_provider.dart';
import 'package:anota_ai/provider/usuario_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/toogle_login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const ToogleGoogleLoginPage(),
      ),
    );
  }
}
