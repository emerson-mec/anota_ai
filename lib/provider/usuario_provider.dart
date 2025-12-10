import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UsuarioProvider extends ChangeNotifier {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Retorna o usuário atual do Firebase
  static User? usuarioAtual() => _auth.currentUser;

  Future<UserCredential?> signInComGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final googleSignIn = GoogleSignIn.instance;

      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      if (googleUser == null) {
        if (kDebugMode) print('Erro Sign-In no UsuarioProvider');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e, st) {
      if (kDebugMode) {
        print('Erro no login com Google');
        print(st);
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) print('Erro ao deslogar: $e');
      rethrow;
    }
  }
}
