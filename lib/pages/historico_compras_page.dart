import 'package:anota_ai/model/compra_model.dart';
import 'package:anota_ai/provider/lista_itens_provider.dart';
import 'package:anota_ai/utils/data_formatada_extensio.dart';
import 'package:anota_ai/utils/moeda_formatada_extension.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class HistoricoComprasPage extends StatefulWidget {
  const HistoricoComprasPage({Key? key}) : super(key: key);

  @override
  State<HistoricoComprasPage> createState() => _HistoricoComprasPageState();
}

class _HistoricoComprasPageState extends State<HistoricoComprasPage> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();
  String _categoriaSelecionada = 'Alimentação';
  bool _visualizarAnual = false;

  final List<String> _categorias = [
    'Alimentação',
    'Transporte',
    'Saúde',
    'Educação',
    'Diversão',
    'Outros',
  ];

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _adicionarCompra() {
    if (_descricaoController.text.isEmpty || _valorController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final valor = double.tryParse(_valorController.text);
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor deve ser maior que zero')),
      );
      return;
    }

    final novaCompra = CompraModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: _dataSelecionada,
      descricao: _descricaoController.text,
      valor: valor,
      categoria: _categoriaSelecionada,
    );

    context.read<ListaItensProvider>().atualizarHistoricoCompras(novaCompra);

    _descricaoController.clear();
    _valorController.clear();
    _dataSelecionada = DateTime.now();
    _categoriaSelecionada = 'Alimentação';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra adicionada com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 76, 154, 103),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção: Nova Compra
              _buildNovaCompraSection(),
              const SizedBox(height: 24),

              // Seção: Evolução Mensal
              _buildEvolucaoMensalSection(),
              const SizedBox(height: 24),

              // Seção: Compras Recentes
              _buildComprasRecentesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNovaCompraSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'NOVA COMPRA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo: Descrição
          TextField(
            controller: _descricaoController,
            decoration: InputDecoration(
              hintText: 'Descrição da compra',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Campo: Valor
          TextField(
            controller: _valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Valor total',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Campo: Categoria
          DropdownButtonFormField<String>(
            value: _categoriaSelecionada,
            items: _categorias
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _categoriaSelecionada = value ?? 'Alimentação';
              });
            },
            decoration: InputDecoration(
              hintText: 'Categoria',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Campo: Data
          GestureDetector(
            onTap: () async {
              final dataSelecionada = await showDatePicker(
                context: context,
                initialDate: _dataSelecionada,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (dataSelecionada != null) {
                setState(() {
                  _dataSelecionada = dataSelecionada;
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Text(
                    _dataSelecionada.diaMesAno(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botão: Salvar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _adicionarCompra,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolucaoMensalSection() {
    return Consumer<ListaItensProvider>(
      builder: (context, provider, _) {
        final historico = provider.historicoCompras;

        if (historico.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Nenhuma compra registrada ainda',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolução mensal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Toggle: Mensal / Anual
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Mensal')),
                      ButtonSegment(value: true, label: Text('Anual')),
                    ],
                    selected: {_visualizarAnual},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _visualizarAnual = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gráfico
            _buildGraficoEvolucao(provider),
          ],
        );
      },
    );
  }

  Widget _buildGraficoEvolucao(ListaItensProvider provider) {
    if (_visualizarAnual) {
      return _buildGraficoAnual(provider);
    } else {
      return _buildGraficoMensal(provider);
    }
  }

  Widget _buildGraficoMensal(ListaItensProvider provider) {
    final totalPorMes = provider.calcularTotalPorMes();

    if (totalPorMes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filtrar últimos 12 meses
    final agora = DateTime.now();
    var dataLimite = DateTime(agora.year, agora.month, 1);
    dataLimite = dataLimite.subtract(const Duration(days: 365));

    final mesesOrdenados =
        totalPorMes.entries.where((entry) {
          final partes = entry.key.split('/');
          final mes = int.parse(partes[0]);
          final ano = int.parse(partes[1]);
          final data = DateTime(ano, mes);
          return data.isAfter(dataLimite) || data.isAtSameMomentAs(dataLimite);
        }).toList()..sort((a, b) {
          final mesA = a.key.split('/');
          final mesB = b.key.split('/');
          final dataA = DateTime(int.parse(mesA[1]), int.parse(mesA[0]));
          final dataB = DateTime(int.parse(mesB[1]), int.parse(mesB[0]));
          return dataA.compareTo(dataB);
        });

    if (mesesOrdenados.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Nenhum dado disponível para este período',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final maxValor = mesesOrdenados
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValor,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= mesesOrdenados.length) {
                    return const Text('');
                  }
                  final mesAno = mesesOrdenados[index].key;
                  final partes = mesAno.split('/');
                  final mes = int.parse(partes[0]);
                  final abreviacoes = [
                    'JAN',
                    'FEV',
                    'MAR',
                    'ABR',
                    'MAI',
                    'JUN',
                    'JUL',
                    'AGO',
                    'SET',
                    'OUT',
                    'NOV',
                    'DEZ',
                  ];
                  return Text(
                    abreviacoes[mes - 1],
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'R\$ ${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(mesesOrdenados.length, (index) {
            final valor = mesesOrdenados[index].value;
            final mesAno = mesesOrdenados[index].key;
            final partes = mesAno.split('/');
            final ano = int.parse(partes[1]);
            final mesAtual = DateTime.now().month;
            final anoAtual = DateTime.now().year;
            final ehMesAtual =
                int.parse(partes[0]) == mesAtual && ano == anoAtual;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: valor,
                  color: ehMesAtual ? Colors.blue : Colors.green[400],
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGraficoAnual(ListaItensProvider provider) {
    final totalPorMes = provider.calcularTotalPorMes();

    if (totalPorMes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filtrar últimos 7 anos e agrupar por ano
    final agora = DateTime.now();
    final dataLimite = DateTime(agora.year - 7, agora.month, agora.day);

    final totalPorAno = <int, double>{};
    for (var entry in totalPorMes.entries) {
      final partes = entry.key.split('/');
      final mes = int.parse(partes[0]);
      final ano = int.parse(partes[1]);
      final data = DateTime(ano, mes);

      if (data.isAfter(dataLimite) || data.isAtSameMomentAs(dataLimite)) {
        totalPorAno[ano] = (totalPorAno[ano] ?? 0.0) + entry.value;
      }
    }

    if (totalPorAno.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Nenhum dado disponível para este período',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final anosOrdenados = totalPorAno.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxValor = anosOrdenados
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final anoAtual = DateTime.now().year;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValor,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= anosOrdenados.length) {
                    return const Text('');
                  }
                  return Text(
                    anosOrdenados[index].key.toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'R\$ ${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(anosOrdenados.length, (index) {
            final ano = anosOrdenados[index].key;
            final valor = anosOrdenados[index].value;
            final ehAnoAtual = ano == anoAtual;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: valor,
                  color: ehAnoAtual ? Colors.blue : Colors.green[400],
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildComprasRecentesSection() {
    return Consumer<ListaItensProvider>(
      builder: (context, provider, _) {
        final comprasRecentes = provider.obterComprasRecentes();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Compras recentes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
          
              ],
            ),
            const SizedBox(height: 12),

            if (comprasRecentes.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Nenhuma compra registrada ainda',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comprasRecentes.length,
                itemBuilder: (context, index) {
                  final compra = comprasRecentes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                compra.descricao,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${compra.data.diaMesAno()} • ${compra.categoria}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '-${compra.valor.emReaisBR()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
