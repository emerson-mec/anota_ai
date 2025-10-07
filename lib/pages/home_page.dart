import 'package:anota_ai/model/lista_model.dart';
import 'package:anota_ai/provider/lista_itens_provider.dart';
import 'package:anota_ai/widget/drawer_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeItemController = TextEditingController();
  final TextEditingController _nomeListaController = TextEditingController();
  late ListaMODEL listaSelecionada;
  final FocusNode _nomeFocusNode = FocusNode();
  bool _isSaving = false;

  @override
  void dispose() {
    _nomeItemController.dispose();
    _nomeListaController.dispose();
    _nomeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("chamou home");
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            'ANOTA AÍ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: '',
              icon: const Icon(Icons.stacked_bar_chart),
              onPressed: () {},
            ),
          ],
        ),
        drawer: DrawerCUSTOM(),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: Provider.of<ListaItensProvider>(
                  context,
                ).getListasItens(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar listas: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Para começar crie uma lista'),
                          TextButton(
                            onPressed: () {
                              _addListBottomSheet();
                            },
                            child: Text("+ CRIAR LISTA"),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final listas = snapshot.data!;
                    String? selectedListaNome = listas
                        .firstWhere(
                          (e) => e.prioridade == true,
                          orElse: () => listas.first,
                        )
                        .nome;
                    return StatefulBuilder(
                      builder: (context, setState) {
                        final selectedLista = listas.firstWhere(
                          (l) => l.nome == selectedListaNome,
                          orElse: () => listas.first,
                        );

                        listaSelecionada = selectedLista;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 40,
                              color: Colors.green[100],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('LISTA: '),
                                  SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: selectedListaNome,
                                    items: listas.map<DropdownMenuItem<String>>(
                                      (lista) {
                                        return DropdownMenuItem<String>(
                                          value: lista.nome,
                                          child: Text(lista.nome),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedListaNome = value;
                                        listaSelecionada = selectedLista;
                                      });
                                      print(listaSelecionada.nome);
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _addListBottomSheet();
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('Item no carrinho'),
                                              Expanded(
                                                child: Wrap(
                                                  children: [
                                                    ...selectedLista.itens
                                                        .where(
                                                          (filtro) =>
                                                              filtro
                                                                  .noCarrinho ==
                                                              true,
                                                        )
                                                        .map(
                                                          (item) => Chip(
                                                            label: InkWell(
                                                              onTap: () {
                                                                print(
                                                                  item.nome,
                                                                );
                                                              },
                                                              child: Text(
                                                                item.nome,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          color: const Color.fromARGB(
                                            255,
                                            213,
                                            213,
                                            213,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('Intenção de compra'),
                                              Expanded(
                                                child: Wrap(
                                                  children: [
                                                    ...selectedLista.itens
                                                        .where(
                                                          (filtro) =>
                                                              filtro
                                                                  .intencaoCompra ==
                                                              true,
                                                        )
                                                        .map(
                                                          (item) => InkWell(
                                                            onTap: () {
                                                              print(item.nome);
                                                            },
                                                            child: Chip(
                                                              label: Text(
                                                                item.nome,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.grey),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Itens da lista "$selectedListaNome"',
                                      ),
                                      InkWell(
                                        onTap: () {
                                          _addItemBottomSheet();
                                        },
                                        child: Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 220,
                                    child: SingleChildScrollView(
                                      child: Wrap(
                                        children: selectedLista.itens.map((
                                          item,
                                        ) {
                                          return InkWell(
                                            onTap: () {
                                              print(item.nome);
                                            },
                                            child: Chip(label: Text(item.nome)),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (Provider.of<ListaItensProvider>(
              context,
              listen: false,
            ).listaItens.isNotEmpty) {
              _addItemBottomSheet();
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Antes crie uma lista')));
            }
          },
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

  Future<void> _addItemBottomSheet() async {
    _nomeItemController.clear();
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
                  controller: _nomeItemController,
                  focusNode: _nomeFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Novo Item',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _nomeItemController.text = value;
                  },
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
                                  var novoItem = ItemMODEL(
                                    idLista: listaSelecionada.id,
                                    id: '123',
                                    nome: _nomeItemController.text,
                                    dataCriacao: Timestamp.now(),
                                  );

                                  Provider.of<ListaItensProvider>(
                                    context,
                                    listen: false,
                                  ).addItem(
                                    idLista: listaSelecionada.id,
                                    novoItem: novoItem,
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
                                        content: Text('Erro ao criar item: $e'),
                                      ),
                                    );
                                  }
                                }
                                // finally {
                                //   if (mounted) {
                                //     setState(() => _isSaving = false);
                                //   }
                                // }
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

  Future<dynamic> _excluirItem(BuildContext context, ListaMODEL lista) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir o item "${lista.nome}"?'),
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
