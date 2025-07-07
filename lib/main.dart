import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'indicadores_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final List<String> _categorias = [
    'Como você avalia nossa experiência geral',
    'Como você avalia nosso atendimento',
    'Como você avalia nosso suporte',
    'Como você avalia nossa internet',
  ];

  final List<Map<String, dynamic>> _emojis = [
    {'emoji': '😡', 'texto': 'Muito insatisfeito', 'valor': 1},
    {'emoji': '😕', 'texto': 'Insatisfeito', 'valor': 2},
    {'emoji': '😐', 'texto': 'Neutro', 'valor': 3},
    {'emoji': '🙂', 'texto': 'Satisfeito', 'valor': 4},
    {'emoji': '😄', 'texto': 'Muito satisfeito', 'valor': 5},
  ];

  @override
  Widget build(BuildContext context) {  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pesquisa de Satisfação',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
          ),
        ),
      ),
      
      home:  IndicadoresScreen(categorias: _categorias, emojis: _emojis,),
    );
  }
}

// class PesquisaSatisfacao extends StatefulWidget {
//   const PesquisaSatisfacao({super.key});

//   @override
//   State<PesquisaSatisfacao> createState() => _PesquisaSatisfacaoState();
// }

// class _PesquisaSatisfacaoState extends State<PesquisaSatisfacao> {
//   final TextEditingController _opiniaoController = TextEditingController();
//   bool _enviado = false;
//   bool _isLoading = false;

//   // Lista de categorias para avaliação
//   final List<String> _categorias = [
//     'Como você avalia nossa experiência geral',
//     'Como você avalia nosso atendimento',
//     'Como você avalia nosso suporte',
//     'Como você avalia nossa internet',
//   ];

//   // Mapa para armazenar as avaliações de cada categoria
//   final Map<String, int?> _avaliacoes = {};

//   final List<Map<String, dynamic>> _emojis = [
//     {'emoji': '😡', 'texto': 'Muito insatisfeito', 'valor': 1},
//     {'emoji': '😕', 'texto': 'Insatisfeito', 'valor': 2},
//     {'emoji': '😐', 'texto': 'Neutro', 'valor': 3},
//     {'emoji': '🙂', 'texto': 'Satisfeito', 'valor': 4},
//     {'emoji': '😄', 'texto': 'Muito satisfeito', 'valor': 5},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     // Inicializa o mapa de avaliações com null para todas as categorias
//     for (var categoria in _categorias) {
//       _avaliacoes[categoria] = null;
//     }
//   }

//   // Verifica se pelo menos uma categoria foi avaliada
//   bool get _temAvaliacao => _avaliacoes.values.any((value) => value != null);

//   // Salva os dados no Firebase
//   Future<void> _salvarNoFirebase() async {
//     // Cria um mapa com os resultados da avaliação
//     final Map<String, dynamic> dados = {};
    
//     // Adiciona cada categoria avaliada ao mapa
//     _avaliacoes.forEach((categoria, index) {
//       if (index != null) {
//         dados[categoria.replaceAll(' ', '_').toLowerCase()] = _emojis[index]['valor'];
//       }
//     });
    
//     // Adiciona a opinião, se houver
//     if (_opiniaoController.text.isNotEmpty) {
//       dados['opiniao'] = _opiniaoController.text;
//     }
    
//     // Adiciona timestamp
//     dados['data_avaliacao'] = FieldValue.serverTimestamp();
    
//     try {
//       // Salva no Firestore
//       await FirebaseFirestore.instance.collection('avaliacoes').add(dados);
//       print('Avaliação salva com sucesso no Firebase!');
//     } catch (e) {
//       print('Erro ao salvar no Firebase: $e');
//       // Você pode adicionar um tratamento de erro mais robusto aqui
//     }
//   }

//   void _enviarAvaliacao() async {
//     if (_temAvaliacao) {
//       setState(() {
//         _isLoading = true;
//       });
      
//       // Salva no Firebase
//       await _salvarNoFirebase();
      
//       setState(() {
//         _enviado = true;
//         _isLoading = false;
//       });
      
//       // Imprime os resultados no console para debug
//       _avaliacoes.forEach((categoria, index) {
//         if (index != null) {
//           print('$categoria: ${_emojis[index]['texto']}');
//         }
//       });
//       if (_opiniaoController.text.isNotEmpty) {
//         print('Opinião: ${_opiniaoController.text}');
//       }
//     }
//   }

//   void _reiniciarPesquisa() {
//     setState(() {
//       for (var categoria in _categorias) {
//         _avaliacoes[categoria] = null;
//       }
//       _opiniaoController.clear();
//       _enviado = false;
//     });
//   }

//   // Navega para a tela de indicadores
//   void _verIndicadores() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => IndicadoresScreen(
//           categorias: _categorias,
//           emojis: _emojis,
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _opiniaoController.dispose();
//     super.dispose();
//   }

//   // Retorna a cor baseada no índice do emoji
//   Color _getColorFromIndex(int? index) {
//     if (index == null) return Colors.grey;
//     switch (index) {
//       case 0: return Colors.red;
//       case 1: return Colors.orange;
//       case 2: return Colors.amber;
//       case 3: return Colors.lightGreen;
//       case 4: return Colors.green;
//       default: return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _isLoading 
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(
//                     color: Colors.blue.shade800,
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Enviando sua avaliação...',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : (_enviado ? _buildAgradecimento() : _buildFormulario()),
//     );
//   }

//   Widget _buildFormulario() {
//     return CustomScrollView(
//       slivers: [
//         // App Bar estilizada
//         SliverAppBar(
//           expandedHeight: 180.0,
//           floating: false,
//           pinned: true,
//           backgroundColor: Colors.blue.shade800,
//           actions: [
//             // Botão para acessar a tela de indicadores
//             IconButton(
//               icon: const Icon(Icons.bar_chart, color: Colors.white),
//               tooltip: 'Ver Indicadores',
//               onPressed: _verIndicadores,
//             ),
//             const SizedBox(width: 8),
//           ],
//           flexibleSpace: FlexibleSpaceBar(
//             title: const Text(
//               'Pesquisa de Satisfação',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             background: Stack(
//               fit: StackFit.expand,
//               children: [
//                 // Gradiente de fundo
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.blue.shade600,
//                         Colors.blue.shade900,
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Padrão de círculos decorativos
//                 Positioned(
//                   top: -50,
//                   right: -30,
//                   child: Container(
//                     width: 150,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.1),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: -60,
//                   left: -30,
//                   child: Container(
//                     width: 180,
//                     height: 180,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.1),
//                     ),
//                   ),
//                 ),
//                 // Ícones de emoji decorativos
//                 Positioned(
//                   top: 40,
//                   right: 20,
//                   child: Row(
//                     children: _emojis.map((emoji) => Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                       child: Text(
//                         emoji['emoji'],
//                         style: TextStyle(
//                           fontSize: 20,
//                           color: Colors.white.withOpacity(0.6),
//                         ),
//                       ),
//                     )).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
        
//         // Conteúdo do formulário
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Card introdutório
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.blue.shade700,
//                         Colors.blue.shade900,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.shade900.withOpacity(0.3),
//                         blurRadius: 15,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.thumb_up_alt,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           const Expanded(
//                             child: Text(
//                               'Sua opinião é muito importante para nós!',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Avalie nossos serviços e nos ajude a melhorar cada vez mais',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 30),
                
//                 // Lista de categorias para avaliação
//                 ..._categorias.map((categoria) => _buildCategoriaAvaliacao(categoria)),
                
//                 const SizedBox(height: 30),
                
//                 // Seção de comentários
//                 Row(
//                   children: [
//                     Container(
//                       width: 4,
//                       height: 24,
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade800,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Deixe sua opinião (opcional)',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: _opiniaoController,
//                     maxLines: 5,
//                     decoration: InputDecoration(
//                       hintText: 'Escreva aqui sua opinião...',
//                       hintStyle: TextStyle(color: Colors.grey.shade500),
//                       contentPadding: const EdgeInsets.all(16),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 30),
                
//                 // Botão de enviar
//                 Container(
//                   height: 60,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: _temAvaliacao ? [
//                       BoxShadow(
//                         color: Colors.blue.shade800.withOpacity(0.3),
//                         blurRadius: 12,
//                         offset: const Offset(0, 6),
//                       ),
//                     ] : null,
//                   ),
//                   child: ElevatedButton(
//                     onPressed: _temAvaliacao ? _enviarAvaliacao : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue.shade800,
//                       foregroundColor: Colors.white,
//                       disabledBackgroundColor: Colors.grey.shade300,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.send_rounded),
//                         const SizedBox(width: 12),
//                         const Text(
//                           'ENVIAR AVALIAÇÃO',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget para cada categoria de avaliação
//   Widget _buildCategoriaAvaliacao(String categoria) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Cabeçalho da categoria
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//               border: Border(
//                 bottom: BorderSide(
//                   color: Colors.grey.shade200,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade100,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     _getCategoryIcon(categoria),
//                     color: Colors.blue.shade800,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     categoria + '?',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//                 ),
//                 if (_avaliacoes[categoria] != null)
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: _getColorFromIndex(_avaliacoes[categoria]).withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       _emojis[_avaliacoes[categoria]!]['emoji'],
//                       style: const TextStyle(fontSize: 20),
//                     ),
//                   ),
//               ],
//             ),
//           ),
          
//           // Emojis para seleção
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: List.generate(_emojis.length, (index) {
//                 final bool isSelected = _avaliacoes[categoria] == index;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _avaliacoes[categoria] = index;
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: isSelected
//                           ? _getColorFromIndex(index).withOpacity(0.2)
//                           : Colors.transparent,
//                       border: Border.all(
//                         color: isSelected
//                             ? _getColorFromIndex(index)
//                             : Colors.transparent,
//                         width: 2,
//                       ),
//                       boxShadow: isSelected ? [
//                         BoxShadow(
//                           color: _getColorFromIndex(index).withOpacity(0.3),
//                           blurRadius: 8,
//                           spreadRadius: 1,
//                         ),
//                       ] : null,
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           _emojis[index]['emoji'],
//                           style: const TextStyle(fontSize: 32),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _emojis[index]['texto'],
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: isSelected
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                             color: isSelected
//                                 ? _getColorFromIndex(index)
//                                 : Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Retorna um ícone baseado na categoria
//   IconData _getCategoryIcon(String categoria) {
//     if (categoria.contains('experiência')) {
//       return Icons.star;
//     } else if (categoria.contains('atendimento')) {
//       return Icons.support_agent;
//     } else if (categoria.contains('suporte')) {
//       return Icons.headset_mic;
//     } else if (categoria.contains('fibra')) {
//       return Icons.wifi;
//     }
//     return Icons.category;
//   }

//   Widget _buildAgradecimento() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.blue.shade600,
//             Colors.blue.shade900,
//           ],
//         ),
//       ),
//       child: Stack(
//         children: [
//           // Elementos decorativos
//           Positioned(
//             top: -100,
//             right: -100,
//             child: Container(
//               width: 300,
//               height: 300,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.1),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -80,
//             left: -80,
//             child: Container(
//               width: 250,
//               height: 250,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.1),
//               ),
//             ),
//           ),
          
//           // Conteúdo principal
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Ícone de sucesso com animação
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 20,
//                         spreadRadius: 5,
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.check_circle_outline,
//                     color: Colors.green,
//                     size: 80,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Obrigado pela sua avaliação!',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: Text(
//                     'Sua opinião é muito importante para melhorarmos nossos serviços.',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white.withOpacity(0.9),
//                       height: 1.5,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 50),
                
//                 // Botão para nova avaliação
//                 Container(
//                   width: 220,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 15,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: _reiniciarPesquisa,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.blue.shade800,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.refresh,
//                           color: Colors.blue.shade800,
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           'NOVAMENTE',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue.shade800,
//                             letterSpacing: 1,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // Botão para ver indicadores
//                 // TextButton.icon(
//                 //   onPressed: _verIndicadores,
//                 //   icon: const Icon(
//                 //     Icons.bar_chart,
//                 //     color: Colors.white,
//                 //   ),
//                 //   label: const Text(
//                 //     'Ver Indicadores',
//                 //     style: TextStyle(
//                 //       color: Colors.white,
//                 //       fontSize: 16,
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }