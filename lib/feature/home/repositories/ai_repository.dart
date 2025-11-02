import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AI APIの種類
enum AIProvider {
  openai,
  claude,
}

/// AIリポジトリのインターフェース
abstract class AIRepository {
  Future<String> generateText({
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 500,
  });
}

/// OpenAI APIリポジトリ
class OpenAIRepository implements AIRepository {
  final String _apiKey;
  final String _baseUrl = 'https://api.openai.com/v1';

  OpenAIRepository({String? apiKey})
      : _apiKey = apiKey ?? dotenv.env['OPENAI_API_KEY'] ?? '';

  @override
  Future<String> generateText({
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 500,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key is not configured');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
    }
  }
}

/// Claude APIリポジトリ
class ClaudeRepository implements AIRepository {
  final String _apiKey;
  final String _baseUrl = 'https://api.anthropic.com/v1';

  ClaudeRepository({String? apiKey})
      : _apiKey = apiKey ?? dotenv.env['ANTHROPIC_API_KEY'] ?? '';

  @override
  Future<String> generateText({
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 500,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Anthropic API key is not configured');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-3-opus-20240229',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['content'][0]['text'] as String;
    } else {
      throw Exception('Claude API error: ${response.statusCode} - ${response.body}');
    }
  }
}

/// AIリポジトリのファクトリ
class AIRepositoryFactory {
  static AIRepository create(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return OpenAIRepository();
      case AIProvider.claude:
        return ClaudeRepository();
    }
  }
}
