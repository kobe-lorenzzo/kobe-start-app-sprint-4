import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../services/ai_service.dart';
import '../2_agenda/screens/create_appointment_screen.dart';

class aiChatScreen extends StatefulWidget {
  const aiChatScreen ({super.key});

  @override
  State<aiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<aiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final AiService _aiService = AiService();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Olá! Diga-me o que deseja agendar.\nEx: "Dentista dia 25/12/2025 as 10h na Av Paulista"',
      'isUser': false,
    }
  ];

  bool _isTyping = false;

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userText = _controller.text;
    setState(() {
      _messages.add({'text': userText, 'isUser': true});
      _isTyping = true;
      _controller.clear();
    });

    try {
      final data = await _aiService.processMessage(userText);

      setState(() {
        _isTyping = false;
        _messages.add({
          'text': 'Entendido! Aqui está o rascunho do seu compromisso:',
          'isUser': false,
          'jsonData': data,
        });
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'text': 'Desculpe, não entendi. Tente novamente.',
            'isUser': false,
        });
      });
    }
  }
  void _openCreateScreen(Map<String, dynamic> data) {
    DateTime? dateObj;
    TimeOfDay? timeObj;

    try {
      if (data['date'] != null) dateObj = DateTime.parse(data['date']);
      if (data['time'] != null) {
        final parts = data['time'].split(':');
        timeObj = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (e) {
      print("Erro ao converter data/hora: $e");
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateAppointmentScreen(
          initialTitle: data['title'],
          initialAddress: data['address'],
          initialDate: dateObj,
          initialTime: timeObj,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Assistente IA"),
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;
                final jsonData = msg['jsonData'] as Map<String, dynamic>?;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.textPurple : AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(12).copyWith(
                        bottomRight: isUser ? Radius.zero : null,
                        bottomLeft: !isUser ? Radius.zero : null,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        
                        if (jsonData != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.textPurple,
                              ),
                              icon: const Icon(Icons.check_circle),
                              label: const Text("Criar Agendamento"),
                              onPressed: () => _openCreateScreen(jsonData),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: AppColors.textPurple),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            color: AppColors.backgroundDark,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Digite seu compromisso...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.textPurple,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

