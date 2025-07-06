import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class IndicadoresScreen extends StatefulWidget {
  final List<String> categorias;
  final List<Map<String, dynamic>> emojis;

  const IndicadoresScreen({
    super.key, 
    required this.categorias, 
    required this.emojis,
  });

  @override
  State<IndicadoresScreen> createState() => _IndicadoresScreenState();
}

class _IndicadoresScreenState extends State<IndicadoresScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, Map<String, dynamic>> _estatisticas = {};
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  String _periodoSelecionado = 'Todos';
  final List<String> _periodos = ['Últimos 7 dias', 'Últimos 30 dias', 'Todos'];
  List<Map<String, dynamic>> _comentarios = [];
  // Mapa para rastrear comentários únicos por ID
  Map<String, bool> _comentariosProcessados = {};

  @override
  void initState() {
    super.initState();
    // Adiciona uma aba extra para os comentários
    _tabController = TabController(length: widget.categorias.length + 1, vsync: this);
    _carregarEstatisticas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Carrega as estatísticas do Firebase
  Future<void> _carregarEstatisticas() async {
    setState(() {
      _isLoading = true;
      _comentariosProcessados.clear(); // Limpa o registro de comentários processados
    });

    try {
      // Prepara a consulta baseada no período selecionado
      Query query = FirebaseFirestore.instance.collection('avaliacoes');
      
      if (_periodoSelecionado == 'Últimos 7 dias') {
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        query = query.where('data_avaliacao', isGreaterThanOrEqualTo: sevenDaysAgo);
      } else if (_periodoSelecionado == 'Últimos 30 dias') {
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        query = query.where('data_avaliacao', isGreaterThanOrEqualTo: thirtyDaysAgo);
      }

      final QuerySnapshot snapshot = await query.get();
      
      // Inicializa o mapa de estatísticas
      final Map<String, Map<String, dynamic>> estatisticas = {};
      
      // Lista para armazenar comentários
      final List<Map<String, dynamic>> comentarios = [];
      
      for (var categoria in widget.categorias) {
        final String campoFirestore = categoria.replaceAll(' ', '_').toLowerCase();
        
        // Inicializa contadores para cada valor de avaliação (1-5)
        final Map<int, int> contadores = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
        int total = 0;
        double media = 0;
        
        // Conta as avaliações
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          
          // Coleta comentários apenas uma vez por documento
          if (data.containsKey('opiniao') && 
              data['opiniao'].toString().trim().isNotEmpty &&
              !_comentariosProcessados.containsKey(doc.id)) {
            
            _comentariosProcessados[doc.id] = true; // Marca como processado
            
            final Map<String, dynamic> comentario = {
              'id': doc.id,
              'texto': data['opiniao'],
              'data': data['data_avaliacao'] is Timestamp 
                  ? (data['data_avaliacao'] as Timestamp).toDate()
                  : DateTime.now(),
              'avaliacoes': {}
            };
            
            // Adiciona as avaliações de cada categoria ao comentário
            for (var cat in widget.categorias) {
              final String campo = cat.replaceAll(' ', '_').toLowerCase();
              if (data.containsKey(campo)) {
                comentario['avaliacoes'][cat] = data[campo];
              }
            }
            
            comentarios.add(comentario);
          }
          
          if (data.containsKey(campoFirestore)) {
            final int valor = data[campoFirestore];
            contadores[valor] = (contadores[valor] ?? 0) + 1;
            total++;
            media += valor;
          }
        }
        
        // Calcula a média
        media = total > 0 ? media / total : 0;
        
        // Armazena as estatísticas
        estatisticas[categoria] = {
          'contadores': contadores,
          'total': total,
          'media': media,
        };
      }
      
      // Ordena comentários por data (mais recentes primeiro)
      comentarios.sort((a, b) => (b['data'] as DateTime).compareTo(a['data'] as DateTime));
      
      setState(() {
        _estatisticas = estatisticas;
        _comentarios = comentarios;
        _isLoading = false;
      });
      
    } catch (e) {
      print('Erro ao carregar estatísticas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Retorna o emoji correspondente à média
  String _getEmojiFromMedia(double media) {
    if (media == 0) return '❓';
    if (media < 1.5) return widget.emojis[0]['emoji']; // Muito insatisfeito
    if (media < 2.5) return widget.emojis[1]['emoji']; // Insatisfeito
    if (media < 3.5) return widget.emojis[2]['emoji']; // Neutro
    if (media < 4.5) return widget.emojis[3]['emoji']; // Satisfeito
    return widget.emojis[4]['emoji']; // Muito satisfeito
  }

  // Retorna a cor correspondente à média
  Color _getColorFromMedia(double media) {
    if (media == 0) return Colors.grey;
    if (media < 1.5) return Colors.red;
    if (media < 2.5) return Colors.orange;
    if (media < 3.5) return Colors.amber;
    if (media < 4.5) return Colors.lightGreen;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: CustomScrollView(
        slivers: [
          // App Bar estilizada
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue.shade800,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Indicadores de Satisfação',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradiente de fundo
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade600,
                          Colors.blue.shade900,
                        ],
                      ),
                    ),
                  ),
                  // Padrão de círculos decorativos
                  Positioned(
                    top: -50,
                    right: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -60,
                    left: -30,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Ícones de emoji decorativos
                  Positioned(
                    top: 40,
                    right: 20,
                    child: Row(
                      children: widget.emojis.map((emoji) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          emoji['emoji'],
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Seletor de período
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Text(
                    'Período:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _periodoSelecionado,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _periodoSelecionado = newValue;
                              });
                              _carregarEstatisticas();
                            }
                          },
                          items: _periodos.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tabs para categorias e comentários
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.blue.shade800,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.blue.shade800,
                indicatorWeight: 3,
                tabs: [
                  ...widget.categorias.map((categoria) {
                    final String categoriaSimples = categoria
                        .replaceAll('Como você avalia ', '')
                        .replaceAll('nossa ', '')
                        .replaceAll('nosso ', '');
                    return Tab(text: categoriaSimples);
                  }).toList(),
                  // Tab adicional para comentários
                  const Tab(text: 'Comentários'),
                ],
              ),
            ),
            pinned: true,
          ),
          
          // Conteúdo principal
          SliverFillRemaining(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      ...widget.categorias.map((categoria) {
                        return _buildCategoriaTab(categoria);
                      }).toList(),
                      // Conteúdo da tab de comentários
                      _buildComentariosTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaTab(String categoria) {
    final estatistica = _estatisticas[categoria];
    
    if (estatistica == null || estatistica['total'] == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma avaliação encontrada\npara esta categoria.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    final Map<int, int> contadores = estatistica['contadores'];
    final int total = estatistica['total'];
    final double media = estatistica['media'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card com média e emoji
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getColorFromMedia(media).withOpacity(0.8),
                  _getColorFromMedia(media).withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getColorFromMedia(media).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getEmojiFromMedia(media),
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Média de Satisfação',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              media.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'de 5.0',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Baseado em $total avaliações',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Título da seção de gráfico
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Distribuição das Avaliações',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Gráfico de barras horizontais com emojis
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final valor = group.x.toInt();
                      final count = contadores[valor] ?? 0;
                      final percent = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
                      return BarTooltipItem(
                        '$count avaliações\n$percent%',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt() - 1;
                        if (index < 0 || index >= widget.emojis.length) {
                          return const Text('');
                        }
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getColorFromMedia(value).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.emojis[index]['emoji'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                      getTitlesWidget: _leftTitleWidgets,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
                barGroups: List.generate(5, (index) {
                  final valor = index + 1;
                  final count = contadores[valor] ?? 0;
                  final percent = total > 0 ? (count / total * 100) : 0.0;
                  
                  return BarChartGroupData(
                    x: valor,
                    barRods: [
                      BarChartRodData(
                        toY: percent,
                        color: _getColorFromMedia(valor.toDouble()),
                        width: 25,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: Colors.grey.shade100,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Título da seção de detalhamento
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Detalhamento',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Lista detalhada de cada tipo de avaliação
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: List.generate(widget.emojis.length, (index) {
                final valor = index + 1;
                final count = contadores[valor] ?? 0;
                final percent = total > 0 ? (count / total * 100) : 0.0;
                
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: index < widget.emojis.length - 1
                        ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getColorFromMedia(valor.toDouble()).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.emojis[index]['emoji'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.emojis[index]['texto'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$count avaliações',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getColorFromMedia(valor.toDouble()).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${percent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getColorFromMedia(valor.toDouble()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Tab para exibir os comentários dos clientes
  Widget _buildComentariosTab() {
    if (_comentarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum comentário encontrado\nno período selecionado.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da seção
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade900,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade900.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Comentários dos Clientes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_comentarios.length} comentários no período',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Veja o que nossos clientes estão dizendo sobre nossos serviços',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Lista de comentários
          ...List.generate(_comentarios.length, (index) {
            final comentario = _comentarios[index];
            final DateTime data = comentario['data'];
            final String texto = comentario['texto'];
            // Corrigindo o problema de tipo aqui
            final Map<String, dynamic> avaliacoes = Map<String, dynamic>.from(comentario['avaliacoes'] ?? {});
            
            // Calcula a média geral das avaliações deste comentário
            double mediaGeral = 0;
            int totalCategorias = 0;
            
            avaliacoes.forEach((categoria, valor) {
              if (valor is int) {
                mediaGeral += valor;
                totalCategorias++;
              }
            });
            
            if (totalCategorias > 0) {
              mediaGeral = mediaGeral / totalCategorias;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do comentário
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getColorFromMedia(mediaGeral).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getEmojiFromMedia(mediaGeral),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cliente',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _dateFormat.format(data),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Média geral
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getColorFromMedia(mediaGeral).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getColorFromMedia(mediaGeral).withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                mediaGeral.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getColorFromMedia(mediaGeral),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.star,
                                size: 16,
                                color: _getColorFromMedia(mediaGeral),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Conteúdo do comentário
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Texto do comentário
                        Text(
                          texto,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                        
                        if (avaliacoes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          // Título para as avaliações
                          Text(
                            'Avaliações por categoria:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Avaliações por categoria
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: avaliacoes.entries.map((entry) {
                              final String categoria = entry.key
                                  .replaceAll('Como você avalia ', '')
                                  .replaceAll('nossa ', '')
                                  .replaceAll('nosso ', '');
                              final int valor = entry.value is int ? entry.value : 0;
                              
                              if (valor < 1 || valor > widget.emojis.length) {
                                return Container(); // Retorna um widget vazio se o valor estiver fora do intervalo
                              }
                              
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getColorFromMedia(valor.toDouble()).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      categoria,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.emojis[valor - 1]['emoji'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Widget para os títulos do eixo Y
Widget _leftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  String text;
  
  if (value == 0) {
    text = '0%';
  } else if (value == 20) {
    text = '20%';
  } else if (value == 40) {
    text = '40%';
  } else if (value == 60) {
    text = '60%';
  } else if (value == 80) {
    text = '80%';
  } else if (value == 100) {
    text = '100%';
  } else {
    return Container();
  }
  
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(text, style: style),
  );
}

// Delegate para o header persistente
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}