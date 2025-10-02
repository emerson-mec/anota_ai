// ignore_for_file: use_build_context_synchronously

import 'package:anota_ai/model/lista_model.dart';
import 'package:anota_ai/provider/lista_itens_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListasPAGE extends StatefulWidget {
  const ListasPAGE({super.key});

  @override
  State<ListasPAGE> createState() => _ListasPAGEState();
}

class _ListasPAGEState extends State<ListasPAGE> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeListaController = TextEditingController();
  final TextEditingController _nomeItemController = TextEditingController();
  final FocusNode _nomeFocusNode = FocusNode();
  bool _isSaving = false;

  @override
  void dispose() {
    _nomeListaController.dispose();
    _nomeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("chamou Listas Page");
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Minhas Listas')),
        body: FutureBuilder(
          future: Provider.of<ListaItensProvider>(context).getListasItens(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar listas: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhuma lista encontrada.'));
            } else {
              final listas = snapshot.data!;

              return ListView(
                children: listas
                    .map(
                      (lista) => ExpansionTile(
                        title: Text(lista.nome),
                        subtitle: Text(
                          '${lista.itens.length} itens | Prioridade: ${lista.prioridade.traduzir}',
                        ),

                        // trailing: IconButton(
                        //   onPressed: () {
                        //     _updateListBottomSheet(lista);
                        //   },
                        //   icon: Icon(Icons.edit),
                        // ),
                        leading: TextButton(
                          onPressed: () {
                            _updateListBottomSheet(lista);
                          },
                          child: Text('Editar'),
                        ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("PRIORIDADE: "),

                              SizedBox(
                                width: 110,
                                child: SwitchListTile(
                                  value: lista.prioridade,
                                  onChanged: (value) async {
                                    await Provider.of<ListaItensProvider>(
                                      context,
                                      listen: false,
                                    ).mudarPrioridade(
                                      idLista: lista.id,
                                      isPrioridade: value,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            children: [
                              ...lista.itens.map((item) {
                                return Chip(
                                  label: Text(item.nome),
                                  onDeleted: () {
                                    _updateItemBottomSheet(lista, item);
                                  },
                                  deleteIcon: Icon(Icons.edit),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    )
                    .toList(),
              );
            }
          },
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: _addListBottomSheet,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _addListBottomSheet() async {
    _nomeListaController.clear();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        // Solicita o foco após o build
        Future.delayed(const Duration(milliseconds: 70), () {
          _nomeFocusNode.requestFocus();
        });
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeListaController,
                  focusNode: _nomeFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Nome da nova lista',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o nome da lista';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;

                                setState(() => _isSaving = true);
                                try {
                                  await Provider.of<ListaItensProvider>(
                                    context,
                                    listen: false,
                                  ).addLista(
                                    ListaMODEL(
                                      id: DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                      nome: _nomeListaController.text,
                                      dataCriacao: Timestamp.now(),
                                    ),
                                  );
                                  if (mounted) {
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Lista criada com sucesso',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erro ao criar lista: $e',
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isSaving = false);
                                  }
                                }
                              },
                        child: const Text('Salvar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateListBottomSheet(ListaMODEL lista) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        // Solicita o foco após o build
        Future.delayed(const Duration(milliseconds: 70), () {
          _nomeFocusNode.requestFocus();
        });
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: lista.nome,
                  onChanged: (value) {
                    _nomeListaController.text = value;
                  },
                  focusNode: _nomeFocusNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Novo nome"),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o nome da lista';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;

                                setState(() => _isSaving = true);
                                try {
                                  lista.nome = _nomeListaController.text;
                                  await Provider.of<ListaItensProvider>(
                                    context,
                                    listen: false,
                                  ).updateLista(lista);

                                  if (mounted) {
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Lista alterada com sucesso',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erro ao atualizar lista: $e',
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isSaving = false);
                                  }
                                }
                              },
                        child: const Text('Salvar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _excluirLista(context, lista);
                      },
                      child: Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateItemBottomSheet(ListaMODEL lista, ItemMODEL item) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        // Solicita o foco após o build
        Future.delayed(const Duration(milliseconds: 70), () {
          _nomeFocusNode.requestFocus();
        });
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: item.nome,
                  onChanged: (value) {
                    _nomeItemController.text = value;
                  },
                  focusNode: _nomeFocusNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Novo nome"),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o nome do item';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                try {
                                  // setState(() => _isSaving = true);
                                  item.nome = _nomeItemController.text;

                                  // print(lista.nome);
                                  // print(item.nome);
                                  await Provider.of<ListaItensProvider>(
                                    context,
                                    listen: false,
                                  ).updateItem(lista, item);

                                  if (mounted) {
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Item alterado com sucesso',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erro ao atualizar item: $e',
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isSaving = false);
                                  }
                                }
                              },
                        child: const Text('Salvar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Provider.of<ListaItensProvider>(
                          context,
                          listen: false,
                        ).deletarItem(lista, item);

                        Navigator.pop(context);
                        
                      },
                      child: Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> _excluirLista(BuildContext context, ListaMODEL lista) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a lista "${lista.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await Provider.of<ListaItensProvider>(
                  context,
                  listen: false,
                ).deleteLista(lista.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lista excluída com sucesso')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir lista: $e')),
                  );
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
