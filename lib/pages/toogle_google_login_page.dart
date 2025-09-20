import 'package:anota_ai/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:anota_ai/provider/usuario_provider.dart';
import 'package:provider/provider.dart';

class ToogleGoogleLoginPage extends StatefulWidget {
  const ToogleGoogleLoginPage({super.key});

  @override
  State<ToogleGoogleLoginPage> createState() => _ToogleGoogleLoginPageState();
}

class _ToogleGoogleLoginPageState extends State<ToogleGoogleLoginPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
     
        if (snapshot.hasData) {
          return HomePage(); // usuário logado
        } else {
          return NaoLogadoPage(); // usuário não logado
        }
      },
    );
  }
}

class NaoLogadoPage extends StatefulWidget {
  const NaoLogadoPage({super.key});

  @override
  State<NaoLogadoPage> createState() => _NaoLogadoPageState();
}

class _NaoLogadoPageState extends State<NaoLogadoPage> {
  entrarComGoogle() async {
    try {
      await Provider.of<UsuarioProvider>(
        context,
        listen: false,
      ).signInComGoogle();

      //NavegacaoCUSTOM.pushReplacement(context, const HomePage());
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Acesso cancelado pelo usuário.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 100, color: Colors.green),
            Text(
              "ANOTA AÍ",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            Text(
              "App de anotações de compras simples e rápido!",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
            ),
            SizedBox(height: 30),
            TextButton.icon(
              onPressed: () => entrarComGoogle(),
              label: Text("Entrar com Google"),
              icon: Icon(Icons.login),
            ),
          ],
        ),
      ),
    );
  }
}
