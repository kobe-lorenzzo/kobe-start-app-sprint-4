import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  Future<Map<String, dynamic>> processMessage(String userMessage) async {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  print("DEBUG: API Key lida do .env: ${apiKey.isNotEmpty ? 'Sucesso (****)' : 'Vazia/Erro'}");
  
    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);

      final prompt = '''
        Aja como uma assistente de agenda.
        Analise: "$userMessage"
        
        Extraia e retorne APENAS um objeto JSON com estas 4 chaves exatas (tudo minúsculo):
        {
          "title": "Titulo do compromisso",
          "address": "Endereço completo (se não houver, invente um plausível em SP)",
          "date": "YYYY-MM-DD" (se não houver, use a data de amanhã: ${DateTime.now().add(const Duration(days: 1))}),
          "time": "HH:MM" (formato 24h)
        }
      ''';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text == null) {
        throw Exception("A API retornou uma resposta vazia.");
      }

      String jsonString = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
          
      return jsonDecode(jsonString);

    } catch (e) {
      print("Erro na integração com Gemini: $e");
      
      return {
        "title": "Erro ao processar nome",
        "address": "Verifique sua API Key",
        "date": DateTime.now().toString().split(' ')[0],
        "time": "00:00"
      };
    }
  }
}