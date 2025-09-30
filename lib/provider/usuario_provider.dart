import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UsuarioProvider extends ChangeNotifier {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;

  // Get current user
  static User? usuarioAtual() {
    if (_auth.currentUser == null) {
      return null;
    }
    return _auth.currentUser;
  }

  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(
        serverClientId:
            '692174332763-afc4fcngmheo7n82qnhi2jf5se6f9jkq.apps.googleusercontent.com',
      );
    }
    isInitialize = true;
  }

  // Sign in with Google
  Future<UserCredential?> signInComGoogle() async {
    try {
      initSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;
      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(['email', 'profile']);
      final accessToken = authorization?.accessToken;
      if (accessToken == null) {
        final authorization2 = await authorizationClient.authorizationForScopes(
          ['email', 'profile'],
        );
        
        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(code: "error", message: "error");
        }
        authorization = authorization2;
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid);
            
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'nome': user.displayName ?? '',
            'email': user.email ?? '',
            'isAssinante': false,
            'dataAssinatura': null,
            'photoURL': user.photoURL ?? '',
          }, SetOptions(merge: true));
        }
      }
      return userCredential;
    }  on FirebaseException catch (e) {
      // Tratar permissão negada especificamente
      if (kDebugMode) {
        print('FirebaseException code=${e.code} message=${e.message}');
      }
      if (e.code == 'permission-denied') {
        throw FirebaseException(
            plugin: e.plugin,
            message: 'Permissão negada ao gravar no Firestore. Verifique as regras de segurança.',
            code: e.code);
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      // ignore: avoid_print
      print('Error signing out: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }
}
