import 'dart:convert';

class CompraModel {
  final String id;
  late DateTime data;
  late String descricao;
  late double valor;
  late String categoria;

  CompraModel({
    required this.id,
    required this.data,
    required this.descricao,
    required this.valor,
    required this.categoria,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data.toIso8601String(),
      'descricao': descricao,
      'valor': valor,
      'categoria': categoria,
    };
  }

  // Converter de JSON
  static CompraModel fromJson(Map<String, dynamic> json) {
    return CompraModel(
      id: json['id'] as String,
      data: DateTime.parse(json['data'] as String),
      descricao: json['descricao'] as String,
      valor: (json['valor'] as num).toDouble(),
      categoria: json['categoria'] as String? ?? 'Outros',
    );
  }

  // Converter para String JSON (para armazenar em Hive)
  String toJsonString() => jsonEncode(toJson());

  // Converter de String JSON
  static CompraModel fromJsonString(String jsonString) {
    return fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  // Copiar com modificações
  CompraModel copyWith({
    String? id,
    DateTime? data,
    String? descricao,
    double? valor,
    String? categoria,
  }) {
    return CompraModel(
      id: id ?? this.id,
      data: data ?? this.data,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      categoria: categoria ?? this.categoria,
    );
  }

  @override
  String toString() =>
      'CompraModel(id: $id, data: $data, descricao: $descricao, valor: $valor, categoria: $categoria)';
}
