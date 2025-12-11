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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erro ao verificar autenticação: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const NaoLogadoPage();
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
  bool _isSigning = false;

  Future<void> entrarComGoogle() async {
    setState(() => _isSigning = true);
    try {
      final res = await Provider.of<UsuarioProvider>(
        context,
        listen: false,
      ).signInComGoogle();

      if (res == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro na page NaoLoagadoPage.')),
        );
        return;
      }

      // Não precisa navegar manualmente: StreamBuilder detectará o authState e mostrará HomePage.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao autenticar')));
    } finally {
      if (mounted) setState(() => _isSigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),

              child: Image.asset(
                'assets/logo/logo.png',
                width: 120,
                height: 120,
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              "ANOTA AÍ",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              "App de anotações de compras.\nSimples, rápido e fácil!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              onPressed: _isSigning ? null : entrarComGoogle,
              icon: _isSigning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(
                _isSigning ? 'ENTRANDO...' : 'ENTRAR',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
