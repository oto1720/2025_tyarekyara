import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AI APIの種類
enum AIProvider {
  openai,
  claude,
  gemini,
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

/// Gemini APIリポジトリ（Google Search連携対応）
class GeminiRepository implements AIRepository {
  final String _apiKey;
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  GeminiRepository({String? apiKey})
      : _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '';

  @override
  Future<String> generateText({
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 500,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key is not configured');
    }

    // Gemini 2.0 Flash
    final response = await http.post(
      Uri.parse('$_baseUrl/models/gemini-2.0-flash:generateContent?key=$_apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': temperature,
          'maxOutputTokens': maxTokens,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Google Search連携でテキストを生成
  /// 戻り値: Map with 'text' (String) and 'groundingChunks' (List)
  Future<Map<String, dynamic>> generateTextWithSearch({
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 5000,  // Google Search Groundingは検索メタデータで大量のトークンを消費するため十分大きく設定
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key is not configured');
    }

    // Google Search (grounding) 対応モデル - Gemini 2.5 Flash（最新）
    // 公式ドキュメント: https://ai.google.dev/gemini-api/docs/grounding
    final url = '$_baseUrl/models/gemini-2.5-flash:generateContent?key=$_apiKey';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
      },
      'tools': [
        {
          'google_search': {}  // 最新のGoogle Search Grounding形式
        }
      ],
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      // レスポンス構造の検証
      if (data['candidates'] == null) {
        throw Exception('Invalid response: candidates is null');
      }

      final candidate = data['candidates'][0];

      if (candidate['content'] == null) {
        throw Exception('Invalid response: content is null');
      }

      final content = candidate['content'];

      if (content['parts'] == null) {
        // finishReasonを確認
        final finishReason = candidate['finishReason'];

        if (finishReason == 'MAX_TOKENS') {
          throw Exception('トークン制限に達しました。maxTokensを増やす必要があります。現在: $maxTokens');
        }

        throw Exception('Invalid response: parts is null');
      }

      final text = content['parts'][0]['text'] as String;

      // groundingMetadataから実際の検索結果のURLを取得
      List<Map<String, dynamic>> groundingChunks = [];
      if (candidate['groundingMetadata'] != null) {
        final groundingMetadata = candidate['groundingMetadata'];
        if (groundingMetadata['groundingChunks'] != null) {
          final chunks = groundingMetadata['groundingChunks'] as List<dynamic>;
          groundingChunks = chunks.map((chunk) {
            final web = chunk['web'];
            if (web != null) {
              return {
                'uri': web['uri'] as String?,
                'title': web['title'] as String?,
              };
            }
            return <String, dynamic>{};
          }).where((chunk) => chunk.isNotEmpty).toList();
        }
      }

      return {
        'text': text,
        'groundingChunks': groundingChunks,
      };
    } else {
      throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
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
      case AIProvider.gemini:
        return GeminiRepository();
    }
  }
}
