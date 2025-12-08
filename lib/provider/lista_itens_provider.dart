import 'dart:convert';

import 'package:anota_ai/model/lista_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider que gerencia listas e itens localmente usando Hive.
class ListaItensProvider extends ChangeNotifier {
  final List<ListaMODEL> _listaItens = [];
  late final Box _box;

  ListaItensProvider() {
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen('anota_ai_listas')) {
      await Hive.openBox('anota_ai_listas');
    }
    _box = Hive.box('anota_ai_listas');
    _loadFromBox();
  }

  void _loadFromBox() {
    _listaItens.clear();
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value is Map) {
        _listaItens.add(ListaMODEL.fromJson(Map<String, dynamic>.from(value)));
      } else if (value is String) {
        final Map<String, dynamic> m = json.decode(value) as Map<String, dynamic>;
        _listaItens.add(ListaMODEL.fromJson(m));
      }
    }
    notifyListeners();
  }

  List<ListaMODEL> get listaItens => List.unmodifiable(_listaItens);

  Future<List<ListaMODEL>> getListasItens() async => listaItens;

  Future<void> _saveLista(ListaMODEL lista) async {
    await _box.put(lista.id, lista.toJson());
  }

  Future<void> addLista(ListaMODEL lista) async {
    lista.id = lista.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : lista.id;
    _listaItens.add(lista);
    await _saveLista(lista);
    notifyListeners();
  }

  Future<void> updateLista(ListaMODEL lista) async {
    final idx = _listaItens.indexWhere((l) => l.id == lista.id);
    if (idx == -1) return;
    _listaItens[idx] = lista;
    await _saveLista(lista);
    notifyListeners();
  }

  Future<void> deleteLista(String id) async {
    await _box.delete(id);
    _listaItens.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  Future<void> addItem({required ItemMODEL novoItem, required String idLista}) async {
    final idx = _listaItens.indexWhere((l) => l.id == idLista);
    if (idx == -1) return;
    _listaItens[idx].itens = List.from(_listaItens[idx].itens)..add(novoItem);
    await _saveLista(_listaItens[idx]);
    notifyListeners();
  }

  Future<void> updateItem(ListaMODEL lista, ItemMODEL item) async {
    final idx = _listaItens.indexWhere((l) => l.id == lista.id);
    if (idx == -1) return;
    final itemIdx = _listaItens[idx].itens.indexWhere((i) => i.id == item.id);
    if (itemIdx == -1) return;
    _listaItens[idx].itens[itemIdx] = item;
    await _saveLista(_listaItens[idx]);
    notifyListeners();
  }

  Future<void> deletarItem(ListaMODEL lista, ItemMODEL item) async {
    final idx = _listaItens.indexWhere((l) => l.id == lista.id);
    if (idx == -1) return;
    _listaItens[idx].itens.removeWhere((i) => i.id == item.id);
    await _saveLista(_listaItens[idx]);
    notifyListeners();
  }

  Future<void> atualizarStatusItem({
    required String idLista,
    required String idItem,
    bool? noCarrinho,
    bool? intencaoCompra,
    bool? fixo,
  }) async {
    final listaIndex = _listaItens.indexWhere((l) => l.id == idLista);
    if (listaIndex == -1) return;
    final itemIndex = _listaItens[listaIndex].itens.indexWhere((it) => it.id == idItem);
    if (itemIndex == -1) return;

    final target = _listaItens[listaIndex].itens[itemIndex];
    if (noCarrinho != null) target.noCarrinho = noCarrinho;
    if (intencaoCompra != null) target.intencaoCompra = intencaoCompra;
    if (fixo != null) target.fixo = fixo;

    await _saveLista(_listaItens[listaIndex]);
    notifyListeners();
  }

  Future<void> removerItemDaSecao({
    required String idLista,
    required String idItem,
  }) async {
    await atualizarStatusItem(idLista: idLista, idItem: idItem, noCarrinho: false, intencaoCompra: false);
  }

  Future<void> resetarLista({required String idLista}) async {
    final listaIndex = _listaItens.indexWhere((l) => l.id == idLista);
    if (listaIndex == -1) return;
    for (var item in _listaItens[listaIndex].itens) {
      item.noCarrinho = false;
      item.intencaoCompra = false;
    }
    await _saveLista(_listaItens[listaIndex]);
    notifyListeners();
  }
}
