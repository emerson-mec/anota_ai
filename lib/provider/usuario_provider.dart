import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UsuarioProvider extends ChangeNotifier {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Retorna o usuário atual do Firebase
  static User? usuarioAtual() => _auth.currentUser;

  /// Tenta efetuar login com Google e retorna `UserCredential` em sucesso.
  /// Retorna `null` se o usuário cancelar ou em caso de erro.
  Future<UserCredential?> signInComGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        if (kDebugMode) print('Usuário cancelou o Google Sign-In');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.idToken;

      if ((idToken == null || idToken.isEmpty) && (accessToken == null || accessToken.isEmpty)) {
        if (kDebugMode) print('Tokens do Google são inválidos');
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (kDebugMode) print('Login Google realizado: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e, st) {
      if (kDebugMode) {
        print('Erro no signInComGoogle: $e');
        print(st);
      }
      return null;
    }
  }

  /// Faz sign out do Google e do Firebase
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) print('Erro ao deslogar: $e');
      rethrow;
    }
  }
}