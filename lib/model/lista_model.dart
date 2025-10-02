import 'package:cloud_firestore/cloud_firestore.dart';

extension BoolCUSTOM on bool {
  String get traduzir => this ? "Sim" : "Não";
}

class ListaMODEL {
  String id;
  String nome;
  Timestamp dataCriacao = Timestamp.now();
  List<ItemMODEL> itens;
  bool prioridade;
  final String cor;

  ListaMODEL({
    required this.id,
    required this.nome,
    required this.dataCriacao,
    this.prioridade = true,
    this.itens = const [],
    this.cor = '808080',
  });

  factory ListaMODEL.fromJson(Map<String, dynamic> json) {
    return ListaMODEL(
      id: json['id'] as String? ?? '',
      prioridade: json['prioridade'],
      nome: json['nome'] as String,
      dataCriacao: json['dataCriacao'] as Timestamp,
      itens:
          (json['itens'] as List<dynamic>?)
              ?.map((item) => ItemMODEL.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      cor: json['cor'] ?? '808080',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'dataCriacao': dataCriacao,
      'prioridade': prioridade,
      'cor' : cor,
    };
  }
}

class ItemMODEL {
  final String id;
  final String idLista;
   String nome;
  final Timestamp dataCriacao;
  final int quantidade;
  final bool noCarrinho;
  final bool intencaoCompra;
  final String cor;

  ItemMODEL({
    this.quantidade = 1,
    required this.idLista,
    required this.id,
    required this.nome,
    required this.dataCriacao,
    this.noCarrinho = false,
    this.intencaoCompra = false,
    this.cor = '808080',
  });

  // 🔄 Converter para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idLista': idLista,
      'nome': nome,
      'quantidade': quantidade,
      'dataCriacao': dataCriacao,
      'noCarrinho': noCarrinho,
      'intencaoCompra': intencaoCompra,
      'cor': cor,
    };
  }

  // 🔄 Converter de Map (Firestore → Dart)
  factory ItemMODEL.fromMap(Map<String, dynamic> map) {
    return ItemMODEL(
      id: map['id'] ?? '',
      idLista: map['idLista'] ?? '',
      quantidade: map['quantidade'],
      nome: map['nome'] ?? '',
      dataCriacao: map['dataCriacao'],
      noCarrinho: map['noCarrinho'],
      intencaoCompra: map['intencaoCompra'],
      cor: map['cor'] ?? '808080',
    );
  }
}
