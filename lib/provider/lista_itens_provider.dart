import 'package:anota_ai/model/lista_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ListaItensProvider extends ChangeNotifier {
  List<ListaMODEL> _listaItens = [
    // ListaMODEL(
    //   id: '1',
    //   nome: 'Lista de Compras',
    //   dataCriacao: Timestamp.now(),
    //   prioridade: false,
    //   itens: [
    //     ItemModel(
    //       id: '1',
    //       nome: 'Leite',
    //       quantidade: 2,
    //       dataCriacao: Timestamp.now(),
    //       noCarrinho: true,
    //       intencaoCompra: false,
    //     ),
    //     ItemModel(
    //       id: '2',
    //       nome: 'Pão',
    //       quantidade: 2,
    //       dataCriacao: Timestamp.now(),
    //       noCarrinho: true,
    //       intencaoCompra: false,
    //     ),
    //     ItemModel(
    //       id: '3',
    //       nome: 'Ovos',
    //       quantidade: 2,
    //       dataCriacao: Timestamp.now(),
    //       noCarrinho: false,
    //       intencaoCompra: true,
    //     ),
    //     ItemModel(
    //       id: '4',
    //       nome: 'Maça',
    //       quantidade: 4,
    //       dataCriacao: Timestamp.now(),
    //       noCarrinho: false,
    //       intencaoCompra: true,
    //     ),
    //     ItemModel(
    //       id: '5',
    //       nome: 'Pepino',
    //       quantidade: 1,
    //       dataCriacao: Timestamp.now(),
    //       noCarrinho: false,
    //       intencaoCompra: true,
    //     ),
    //     ItemModel(
    //       id: '6',
    //       nome: 'Iogurte',
    //       quantidade: 1,
    //       dataCriacao: Timestamp.now(),
    //       noCarrinho: false,
    //       intencaoCompra: false,
    //     ),
    //   ],
    // ),
    // ListaMODEL(
    //   id: '2',
    //   nome: 'Tarefas de Casa',
    //   dataCriacao: Timestamp.now(),
    //   prioridade: true,
    //   itens: [
    //     ItemModel(
    //       id: '4',
    //       quantidade: 2,
    //       nome: 'Limpar a cozinha',
    //       dataCriacao: Timestamp.now(),
    //       noCarrinho: false,
    //       intencaoCompra: false,
    //     ),
    //     ItemModel(
    //       id: '5',
    //       nome: 'Lavar o carro',
    //       quantidade: 2,
    //       dataCriacao: Timestamp.now(),
    //       noCarrinho: true,
    //       intencaoCompra: false,
    //     ),
    //     ItemModel(
    //       id: '6',
    //       nome: 'Cortar a grama',
    //       quantidade: 2,
    //       dataCriacao: Timestamp.now(),
    //       noCarrinho: false,
    //       intencaoCompra: false,
    //     ),
    //   ],
    // ),
    // ListaMODEL(
    //   prioridade: false,
    //   id: '3',
    //   nome: 'Projetos de Trabalho',
    //   dataCriacao: Timestamp.now(),
    //   itens: [],
    // ),
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _usuario = FirebaseAuth.instance;

  List<ListaMODEL> get listaItens => _listaItens;

  Future<List<ListaMODEL>> getListasItens() async {
    try {
      // Busca as listas do Firestore e seus itens, e armazena em _listaItens
      if (_usuario.currentUser == null) {
        return [];
      }

      final listasSnapshot = await _firestore
          .collection('usuarios')
          .doc(_usuario.currentUser!.uid)
          .collection('listas')
          .get();

      List<ListaMODEL> listas = [];

      for (var doc in listasSnapshot.docs) {
        // Busca os itens de cada lista
        final itensSnapshot = await _firestore
            .collection('usuarios')
            .doc(_usuario.currentUser!.uid)
            .collection('listas')
            .doc(doc.id)
            .collection('itens')
            .get();

        final itens = itensSnapshot.docs.map((itemDoc) {
          final data = itemDoc.data();
          return ItemMODEL.fromMap(data);
        }).toList();

        final listaData = doc.data();
        final lista = ListaMODEL.fromJson(listaData);
        lista.itens = itens;
        listas.add(lista);
      }

      _listaItens = listas;
      return _listaItens;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar: $e');
      }
    }

    return _listaItens;
  }

  Future deleteLista(String id) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(_usuario.currentUser!.uid)
          .collection('listas')
          .doc(id)
          .delete();
      _listaItens.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao deletar lista do Firestore: $e');
      }
    }
  }

  Future<void> deletarItem(ListaMODEL lista, ItemMODEL item) async {
    try {
      if (_usuario.currentUser != null) {
        await _firestore
            .collection('usuarios')
            .doc(_usuario.currentUser!.uid)
            .collection('listas')
            .doc(lista.id)
            .collection('itens')
            .doc(item.id)
            .delete();

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar lista no Firestore: $e');
      }
    }
  }

  Future<void> addLista(ListaMODEL lista) async {
    try {
      if (_usuario.currentUser != null) {
        var ref = _firestore
            .collection('usuarios')
            .doc(_usuario.currentUser!.uid)
            .collection('listas');

        var ref2 = await ref.add(lista.toJson());

        lista.id = ref2.id;
        await ref2.update({'id': ref2.id});

        _listaItens.add(lista);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar lista ao Firestore: $e');
      }
    }
    _listaItens.add(lista);
    notifyListeners();
  }

  Future<void> updateLista(ListaMODEL lista) async {
    try {
      if (_usuario.currentUser != null) {
        await _firestore
            .collection('usuarios')
            .doc(_usuario.currentUser!.uid)
            .collection('listas')
            .doc(lista.id)
            .update(lista.toJson());

        print(lista.id);

        int index = _listaItens.indexWhere((item) => item.id == lista.id);
        if (index != -1) {
          _listaItens[index] = lista;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar lista no Firestore: $e');
      }
    }
  }

  Future<void> updateItem(ListaMODEL lista, ItemMODEL item) async {
    try {
      if (_usuario.currentUser != null) {
        print(lista.nome);
        print(item.nome);

        await _firestore
            .collection('usuarios')
            .doc(_usuario.currentUser!.uid)
            .collection('listas')
            .doc(lista.id)
            .collection('itens')
            .doc(item.id)
            .update({"nome": item.nome});

        int index = _listaItens.indexWhere((item) => item.id == lista.id);
        if (index != -1) {
          _listaItens[index] = lista;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar lista no Firestore: $e');
      }
    }
  }

  Future<void> mudarPrioridade({
    required String idLista,
    required bool isPrioridade
  }) async {
    await _firestore
        .collection('usuarios')
        .doc(_usuario.currentUser!.uid)
        .collection('listas')
        .doc(idLista)
        .update({'prioridade': isPrioridade});

    notifyListeners();
  }

  Future<void> addItem({
    required ItemMODEL novoItem,
    required String idLista,
  }) async {
    try {
      if (_usuario.currentUser != null) {
        var ref = _firestore
            .collection('usuarios')
            .doc(_usuario.currentUser!.uid)
            .collection('listas')
            .doc(idLista)
            .collection('itens');

        var item = await ref.add(novoItem.toMap());

        // lista.id = item.id;
        await item.update({'id': item.id});

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar lista ao Firestore: $e');
      }
    }
  }

  Future<void> atualizarStatusItem({
    required String idLista,
    required String idItem,
    bool? noCarrinho,
    bool? intencaoCompra,
  }) async {
    try {
      if (_usuario.currentUser != null) {
        Map<String, dynamic> updateData = {};
        
        if (noCarrinho != null) {
          updateData['noCarrinho'] = noCarrinho;
        }
        if (intencaoCompra != null) {
          updateData['intencaoCompra'] = intencaoCompra;
        }

        await _firestore
            .collection('usuarios')
            .doc(_usuario.currentUser!.uid)
            .collection('listas')
            .doc(idLista)
            .collection('itens')
            .doc(idItem)
            .update(updateData);

        // Atualizar o item na lista local
        final listaIndex = _listaItens.indexWhere((lista) => lista.id == idLista);
        if (listaIndex != -1) {
          final itemIndex = _listaItens[listaIndex].itens.indexWhere((item) => item.id == idItem);
          if (itemIndex != -1) {
            if (noCarrinho != null) {
              _listaItens[listaIndex].itens[itemIndex].noCarrinho = noCarrinho;
            }
            if (intencaoCompra != null) {
              _listaItens[listaIndex].itens[itemIndex].intencaoCompra = intencaoCompra;
            }
          }
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar status do item: $e');
      }
    }
  }

  Future<void> removerItemDaSecao({
    required String idLista,
    required String idItem,
  }) async {
    try {
      if (_usuario.currentUser != null) {
        await _firestore
            .collection('usuarios')
            .doc(_usuario.currentUser!.uid)
            .collection('listas')
            .doc(idLista)
            .collection('itens')
            .doc(idItem)
            .update({
          'noCarrinho': false,
          'intencaoCompra': false,
        });

        // Atualizar o item na lista local
        final listaIndex = _listaItens.indexWhere((lista) => lista.id == idLista);
        if (listaIndex != -1) {
          final itemIndex = _listaItens[listaIndex].itens.indexWhere((item) => item.id == idItem);
          if (itemIndex != -1) {
            _listaItens[listaIndex].itens[itemIndex].noCarrinho = false;
            _listaItens[listaIndex].itens[itemIndex].intencaoCompra = false;
          }
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao remover item da seção: $e');
      }
    }
  }

  Future<void> resetarLista({
    required String idLista,
  }) async {
    try {
      if (_usuario.currentUser != null) {
        // Buscar todos os itens da lista que estão em intenção de compra ou no carrinho
        final itensSnapshot = await _firestore
            .collection('usuarios')
            .doc(_usuario.currentUser!.uid)
            .collection('listas')
            .doc(idLista)
            .collection('itens')
            .where('noCarrinho', isEqualTo: true)
            .get();

        final itensIntencaoSnapshot = await _firestore
            .collection('usuarios')
            .doc(_usuario.currentUser!.uid)
            .collection('listas')
            .doc(idLista)
            .collection('itens')
            .where('intencaoCompra', isEqualTo: true)
            .get();

        // Resetar todos os itens no carrinho
        for (var doc in itensSnapshot.docs) {
          await doc.reference.update({
            'noCarrinho': false,
            'intencaoCompra': false,
          });
        }

        // Resetar todos os itens em intenção de compra
        for (var doc in itensIntencaoSnapshot.docs) {
          await doc.reference.update({
            'noCarrinho': false,
            'intencaoCompra': false,
          });
        }

        // Atualizar a lista local
        final listaIndex = _listaItens.indexWhere((lista) => lista.id == idLista);
        if (listaIndex != -1) {
          for (var item in _listaItens[listaIndex].itens) {
            item.noCarrinho = false;
            item.intencaoCompra = false;
          }
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao resetar lista: $e');
      }
    }
  }
}
