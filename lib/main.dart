import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pesquisa de Satisfação',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PesquisaSatisfacao(),
    );
  }
}

class PesquisaSatisfacao extends StatefulWidget {
  const PesquisaSatisfacao({super.key});

  @override
  State<PesquisaSatisfacao> createState() => _PesquisaSatisfacaoState();
}

class _PesquisaSatisfacaoState extends State<PesquisaSatisfacao> {
  int? _selectedEmojiIndex;
  final TextEditingController _opiniaoController = TextEditingController();
  bool _enviado = false;

  final List<Map<String, dynamic>> _emojis = [
    {'emoji': '😡', 'texto': 'Muito insatisfeito'},
    {'emoji': '😕', 'texto': 'Insatisfeito'},
    {'emoji': '😐', 'texto': 'Neutro'},
    {'emoji': '🙂', 'texto': 'Satisfeito'},
    {'emoji': '😄', 'texto': 'Muito satisfeito'},
  ];

  void _enviarAvaliacao() {
    if (_selectedEmojiIndex != null) {
      setState(() {
        _enviado = true;
      });
      // Aqui você pode implementar o código para enviar a avaliação para um servidor
      print('Avaliação: ${_emojis[_selectedEmojiIndex!]['texto']}');
      print('Opinião: ${_opiniaoController.text}');
    }
  }

  void _reiniciarPesquisa() {
    setState(() {
      _selectedEmojiIndex = null;
      _opiniaoController.clear();
      _enviado = false;
    });
  }

  @override
  void dispose() {
    _opiniaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pesquisa de Satisfação'),
      ),
      body: _enviado ? _buildAgradecimento() : _buildFormulario(),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Como você avalia sua experiência?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_emojis.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEmojiIndex = index;
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedEmojiIndex == index
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.transparent,
                          border: Border.all(
                            color: _selectedEmojiIndex == index
                                ? Colors.blue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _emojis[index]['emoji'],
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _emojis[index]['texto'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _selectedEmojiIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            const Text(
              'Deixe sua opinião (opcional):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _opiniaoController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Escreva aqui sua opinião...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectedEmojiIndex != null ? _enviarAvaliacao : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'ENVIAR AVALIAÇÃO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgradecimento() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 100,
          ),
          const SizedBox(height: 20),
          const Text(
            'Obrigado pela sua avaliação!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Sua opinião é muito importante para nós.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _reiniciarPesquisa,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('NOVA AVALIAÇÃO'),
          ),
        ],
      ),
    );
  }
}