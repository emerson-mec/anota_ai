import 'package:anota_ai/model/lista_model.dart';
import 'package:anota_ai/provider/lista_itens_provider.dart';
import 'package:anota_ai/widget/drawer_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      // Exemplo: versão + build number (1.0.0+1)
      final versao = '${info.version}';
      if (mounted) setState(() => _appVersion = versao);
    } catch (e) {
      if (mounted) setState(() => _appVersion = 'versão desconhecida');
    }
  }

  @override
  void dispose() {
    _nomeItemController.dispose();
    _nomeListaController.dispose();
    _nomeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo/logo.png', width: 32, height: 32),
            ),
            SizedBox(width: 8),
            Text('ANOTA AÍ', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Resetar Lista',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _resetarLista();
            },
          ),

          IconButton(
            tooltip: 'Dúvidas',
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Dúvidas Frequentes'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(
                            '1. Como remover um único item da lista de "intensão de compra" ou do "carrinho"?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R: Pressione e segure o item que deseja remover até que o item seja removido da lista.',
                          ),
                          SizedBox(height: 10),
                          Text(
                            '2. Como editar item ou uma lista?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R: Acesse o menu lateral esquerdo e clique em "Gerenciar Listas", onde é possível editar ou excluir listas e itens.',
                          ),
                          Divider(),
                          Text(
                            "Versão do App: $_appVersion",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Fechar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: DrawerCUSTOM(appVersion: _appVersion),
      body: SafeArea(
        child: Column(
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
                              margin: const EdgeInsets.only(
                                top: 8,
                                left: 8,
                                right: 8,
                                bottom: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue[50]!,
                                    const Color.fromARGB(255, 151, 207, 252),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue[200]!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(
                                      78,
                                      12,
                                      92,
                                      158,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.list_alt,
                                      color: Colors.blue[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'LISTA:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: selectedListaNome,
                                        isExpanded: true,
                                        underline: const SizedBox(),
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                        items: listas
                                            .map<DropdownMenuItem<String>>((
                                              lista,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: lista.nome,
                                                child: Text(
                                                  lista.nome,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            })
                                            .toList(),
                                        onChanged: (value) async {
                                          if (value != null &&
                                              value != selectedListaNome) {
                                            // Encontrar a lista selecionada
                                            final novaLista = listas.firstWhere(
                                              (l) => l.nome == value,
                                              orElse: () => listas.first,
                                            );

                                            // Chamar mudarPrioridade para marcar a nova lista como prioritária
                                            await Provider.of<
                                                  ListaItensProvider
                                                >(context, listen: false)
                                                .mudarPrioridade(
                                                  novaLista.id,
                                                  true,
                                                );

                                            setState(() {
                                              selectedListaNome = value;
                                              listaSelecionada = novaLista;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _addListBottomSheet();
                                      },
                                      icon: Icon(
                                        Icons.add_circle,
                                        color: Colors.blue[700],
                                      ),
                                      tooltip: 'Criar nova lista',
                                    ),
                                  ],
                                ),
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
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              top: 5,
                                              left: 8,
                                              right: 4,
                                              bottom: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.green[200]!,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[100],
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                12,
                                                              ),
                                                          topRight:
                                                              Radius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.shopping_cart,
                                                        color:
                                                            Colors.green[700],
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        '${selectedLista.itens.where((i) => i.noCarrinho).length} Itens no carrinho ',

                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.green[700],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 5,
                                                          left: 0,
                                                          right: 0,
                                                          bottom: 3,
                                                        ),
                                                    child:
                                                        selectedLista.itens.where((
                                                          filtro,
                                                        ) {
                                                          return filtro
                                                                  .noCarrinho ==
                                                              true;
                                                        }).isEmpty
                                                        ? Center(
                                                            child: Text(
                                                              'Nenhum item no carrinho',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          )
                                                        : SingleChildScrollView(
                                                            child: Wrap(
                                                              spacing: 6,
                                                              runSpacing: 6,
                                                              children: selectedLista
                                                                  .itens
                                                                  .where(
                                                                    (filtro) =>
                                                                        filtro
                                                                            .noCarrinho ==
                                                                        true,
                                                                  )
                                                                  .map(
                                                                    (
                                                                      item,
                                                                    ) => Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .green[400],
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                        border: BoxBorder.all(
                                                                          color:
                                                                              Colors.green[500]!,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.green[300]!,
                                                                            blurRadius:
                                                                                3,
                                                                            offset: const Offset(
                                                                              0,
                                                                              2,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: InkWell(
                                                                        onLongPress: () {
                                                                          _removerItemDaSecao(
                                                                            selectedLista,
                                                                            item,
                                                                          );
                                                                        },
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              20,
                                                                            ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                            vertical:
                                                                                4,
                                                                          ),
                                                                          child: Text(
                                                                            item.nome,
                                                                            style: const TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 13,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Container(
                                        //   width: 2,
                                        //   height: 60,
                                        //   margin: const EdgeInsets.symmetric(horizontal: 8),
                                        //   decoration: BoxDecoration(
                                        //     color: Colors.grey[300],
                                        //     borderRadius: BorderRadius.circular(1),
                                        //   ),
                                        // ),
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              top: 5,
                                              left: 4,
                                              right: 8,
                                              bottom: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.yellow[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.yellow[600]!,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[100],
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                12,
                                                              ),
                                                          topRight:
                                                              Radius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.favorite,
                                                        color:
                                                            Colors.orange[700],
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'Intenção de compra',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .orange[700],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 5,
                                                          left: 0,
                                                          right: 0,
                                                          bottom: 3,
                                                        ),
                                                    child:
                                                        selectedLista.itens
                                                            .where(
                                                              (filtro) =>
                                                                  filtro
                                                                      .intencaoCompra ==
                                                                  true,
                                                            )
                                                            .isEmpty
                                                        ? Center(
                                                            child: Text(
                                                              'Nenhum item em intenção',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          )
                                                        : SingleChildScrollView(
                                                            child: Wrap(
                                                              spacing: 6,
                                                              runSpacing: 6,
                                                              children: selectedLista
                                                                  .itens
                                                                  .where(
                                                                    (filtro) =>
                                                                        filtro
                                                                            .intencaoCompra ==
                                                                        true,
                                                                  )
                                                                  .map(
                                                                    (
                                                                      item,
                                                                    ) => Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .orange[400],
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                        border: BoxBorder.all(
                                                                          color:
                                                                              Colors.orange[500]!,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.orange[300]!,
                                                                            blurRadius:
                                                                                4,
                                                                            offset: const Offset(
                                                                              0,
                                                                              2,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          _moverParaCarrinho(
                                                                            selectedLista,
                                                                            item,
                                                                          );
                                                                        },
                                                                        onLongPress: () {
                                                                          _removerItemDaSecao(
                                                                            selectedLista,
                                                                            item,
                                                                          );
                                                                        },

                                                                        child: Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                9,
                                                                            vertical:
                                                                                6,
                                                                          ),
                                                                          child: Text(
                                                                            item.nome,
                                                                            style: const TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 13,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[400]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 15),
                                              Icon(
                                                Icons.checklist,
                                                color: Colors.grey[700],
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Itens da lista "$selectedListaNome"',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color.fromARGB(
                                                      255,
                                                      129,
                                                      129,
                                                      129,
                                                    ),
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () {
                                                  _addItemBottomSheet();
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[500],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          constraints: const BoxConstraints(
                                            maxHeight: 200,
                                          ),
                                          child:
                                              selectedLista.itens
                                                  .where(
                                                    (item) =>
                                                        !item.noCarrinho &&
                                                        !item.intencaoCompra,
                                                  )
                                                  .isEmpty
                                              ? Padding(
                                                  padding: const EdgeInsets.all(
                                                    24,
                                                  ),
                                                  child: Text(
                                                    'Nenhum item disponível',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              : SingleChildScrollView(
                                                  child: Wrap(
                                                    spacing: 4,
                                                    runSpacing: 6,
                                                    children: () {
                                                      final itensDisponiveis =
                                                          selectedLista.itens
                                                              .where(
                                                                (item) =>
                                                                    !item
                                                                        .noCarrinho &&
                                                                    !item
                                                                        .intencaoCompra,
                                                              )
                                                              .toList();
                                                      itensDisponiveis.sort(
                                                        (a, b) => a.nome
                                                            .toLowerCase()
                                                            .compareTo(
                                                              b.nome
                                                                  .toLowerCase(),
                                                            ),
                                                      );
                                                      return itensDisponiveis.map((
                                                        item,
                                                      ) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .blue[400],
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            border: Border.all(
                                                              color: Colors
                                                                  .blue[600]!,
                                                              width: 1.5,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .blue[100]!,
                                                                blurRadius: 2,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      1,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              _moverParaIntencaoCompra(
                                                                selectedLista,
                                                                item,
                                                              );
                                                            },
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical: 6,
                                                                  ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  // Icon(
                                                                  //   Icons.add_shopping_cart,
                                                                  //   color: Colors.blue[600],
                                                                  //   size: 16,
                                                                  // ),
                                                                  // const SizedBox(width: 6),
                                                                  Text(
                                                                    item.nome,
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList();
                                                    }(),
                                                  ),
                                                ),
                                        ),
                                      ],
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
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     if (Provider.of<ListaItensProvider>(
      //       context,
      //       listen: false,
      //     ).listaItens.isNotEmpty) {
      //       _addItemBottomSheet();
      //     } else {
      //       ScaffoldMessenger.of(
      //         context,
      //       ).showSnackBar(SnackBar(content: Text('Antes crie uma lista')));
      //     }
      //   },
      //   child: const Icon(Icons.add),
      // ),
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
                                      dataCriacao: DateTime.now(),
                                    ),
                                  );
                                  if (mounted) {
                                    Navigator.of(ctx).pop();
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content: Text(
                                    //       'Lista criada com sucesso',
                                    //     ),
                                    //   ),
                                    // );
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
                                    id: DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                    nome: _nomeItemController.text,
                                    dataCriacao: DateTime.now(),
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
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content: Text(
                                    //       'Lista criada com sucesso',
                                    //     ),
                                    //   ),
                                    // );
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

  Future<void> _moverParaIntencaoCompra(
    ListaMODEL lista,
    ItemMODEL item,
  ) async {
    try {
      await Provider.of<ListaItensProvider>(
        context,
        listen: false,
      ).atualizarStatusItem(
        idLista: lista.id,
        idItem: item.id,
        intencaoCompra: true,
      );

      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('${item.nome} movido para intenção de compra')),
      //   );
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao mover item: $e')));
      }
    }
  }

  Future<void> _moverParaCarrinho(ListaMODEL lista, ItemMODEL item) async {
    try {
      await Provider.of<ListaItensProvider>(
        context,
        listen: false,
      ).atualizarStatusItem(
        idLista: lista.id,
        idItem: item.id,
        noCarrinho: true,
        intencaoCompra: false,
      );

      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('${item.nome} movido para o carrinho')),
      //   );
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao mover item: $e')));
      }
    }
  }

  Future<void> _removerItemDaSecao(ListaMODEL lista, ItemMODEL item) async {
    try {
      await Provider.of<ListaItensProvider>(
        context,
        listen: false,
      ).removerItemDaSecao(idLista: lista.id, idItem: item.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao remover item: $e')));
      }
    }
  }

  Future<void> _resetarLista() async {
    // Verificar se há itens para resetar
    final itensNoCarrinho = listaSelecionada.itens
        .where((item) => item.noCarrinho)
        .length;
    final itensIntencao = listaSelecionada.itens
        .where((item) => item.intencaoCompra)
        .length;

    if (itensNoCarrinho == 0 && itensIntencao == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não há itens para resetar')),
        );
      }
      return;
    }

    // Mostrar diálogo de confirmação
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetar Itens'),
        content: Text(
          'Esta ação limpará apenas "intenção de compra" e "item no carrinho".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await Provider.of<ListaItensProvider>(
          context,
          listen: false,
        ).resetarLista(idLista: listaSelecionada.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lista "${listaSelecionada.nome}" resetada com sucesso',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao resetar lista: $e')));
        }
      }
    }
  }
}
