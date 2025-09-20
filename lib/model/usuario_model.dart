
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String nome;
  final String email;
  final String? photoURL;
  final bool isAssinante;
  final Timestamp? dataAssinatura;
  final String idColaborador;

  Usuario({
    this.photoURL,
    required this.uid,
    required this.nome,
    required this.email,
    this.isAssinante = false,
    this.dataAssinatura,
    this.idColaborador = '',
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      uid: json['uid'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      isAssinante: json['isAssinante'] as bool,
      photoURL: json['photoURL'] as String? ,
      dataAssinatura: json['dataAssinatura'] as Timestamp?,
      idColaborador: json['idColaborador'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'isAssinante': isAssinante,
      'photoURL': photoURL,
      'dataAssinatura': dataAssinatura,
      'idColaborador': idColaborador,
    };
  }
}
