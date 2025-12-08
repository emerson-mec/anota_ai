extension BoolCUSTOM on bool {
  String get traduzir => this ? "Sim" : "Não";
}

class ListaMODEL {
  String id;
  String nome;
  DateTime dataCriacao;
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
      prioridade: json['prioridade'] ?? false,
      nome: json['nome'] as String? ?? '',
      dataCriacao: DateTime.fromMillisecondsSinceEpoch(json['dataCriacao'] ?? 0),
      itens: (json['itens'] as List<dynamic>?)
              ?.map((item) => ItemMODEL.fromMap(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      cor: json['cor'] ?? '808080',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'dataCriacao': dataCriacao.millisecondsSinceEpoch,
      'prioridade': prioridade,
      'cor': cor,
      'itens': itens.map((i) => i.toMap()).toList(),
    };
  }
}

class ItemMODEL {
  final String id;
  final String idLista;
  String nome;
  DateTime dataCriacao;
  int quantidade;
  bool noCarrinho;
  bool intencaoCompra;
  bool fixo;
  final String cor;

  ItemMODEL({
    this.quantidade = 1,
    required this.idLista,
    required this.id,
    required this.nome,
    required this.dataCriacao,
    this.noCarrinho = false,
    this.intencaoCompra = false,
    this.fixo = false,
    this.cor = '808080',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idLista': idLista,
      'nome': nome,
      'quantidade': quantidade,
      'dataCriacao': dataCriacao.millisecondsSinceEpoch,
      'noCarrinho': noCarrinho,
      'intencaoCompra': intencaoCompra,
      'fixo': fixo,
      'cor': cor,
    };
  }

  factory ItemMODEL.fromMap(Map<String, dynamic> map) {
    return ItemMODEL(
      id: map['id'] ?? '',
      idLista: map['idLista'] ?? '',
      quantidade: (map['quantidade'] is int) ? map['quantidade'] : int.tryParse(map['quantidade']?.toString() ?? '1') ?? 1,
      nome: map['nome'] ?? '',
      dataCriacao: DateTime.fromMillisecondsSinceEpoch((map['dataCriacao'] is int) ? map['dataCriacao'] : int.tryParse(map['dataCriacao']?.toString() ?? '0') ?? 0),
      noCarrinho: map['noCarrinho'] ?? false,
      intencaoCompra: map['intencaoCompra'] ?? false,
      fixo: map['fixo'] ?? false,
      cor: map['cor'] ?? '808080',
    );
  }
}
