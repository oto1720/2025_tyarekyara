import 'dart:convert';
import '../models/topic.dart';
import '../repositories/ai_repository.dart';
import 'package:flutter/foundation.dart';

/// トピック分類の結果
class ClassificationResult {
  final TopicCategory category;
  final TopicDifficulty difficulty;
  final List<String> tags;

  ClassificationResult({
    required this.category,
    required this.difficulty,
    this.tags = const [],
  });

  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    return ClassificationResult(
      category: TopicCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TopicCategory.daily,
      ),
      difficulty: TopicDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => TopicDifficulty.medium,
      ),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

/// トピック分類サービス
class TopicClassifierService {
  final AIRepository _aiRepository;

  TopicClassifierService(this._aiRepository);

  /// トピックを分類
  Future<ClassificationResult> classifyTopic(String topicText) async {
    final prompt = _buildClassificationPrompt(topicText);
    final response = await _aiRepository.generateText(
      prompt: prompt,
      temperature: 0.3, // 分類タスクなので低めに設定
      maxTokens: 200,
    );

    return _parseClassificationResponse(response);
  }

  /// 分類用のプロンプトを構築
  String _buildClassificationPrompt(String topicText) {
    return '''
あなたはトピックを分類する専門家です。
以下のトピックを分析し、カテゴリ、難易度、タグを判定してください。

## トピック
$topicText

## カテゴリ（以下のいずれか1つを選択）
- daily: 日常生活や身近なテーマについての話題
- social: 社会問題や時事的なテーマについての話題
- value: 価値観や人生観についての深いテーマ

## 難易度（以下のいずれか1つを選択）
- easy: 気軽に答えられる話題
- medium: 少し考える必要がある話題
- hard: 深い思考が必要な話題

## タグ
トピックに関連する3-5個のキーワードをリストアップしてください。

## 出力形式
以下のJSON形式で出力してください。JSON以外の文字は含めないでください。
{
  "category": "daily" | "social" | "value",
  "difficulty": "easy" | "medium" | "hard",
  "tags": ["タグ1", "タグ2", "タグ3"]
}
''';
  }

  /// 分類レスポンスをパース
  ClassificationResult _parseClassificationResponse(String response) {
    try {
      // JSONブロックを抽出（```json ... ``` で囲まれている場合に対応）
      final jsonMatch = RegExp(r'```json\s*(.*?)\s*```', dotAll: true)
          .firstMatch(response);
      final jsonString = jsonMatch?.group(1) ?? response;

      final json = jsonDecode(jsonString.trim()) as Map<String, dynamic>;
      return ClassificationResult.fromJson(json);
    } catch (e) {
      // パースに失敗した場合はデフォルト値を返す
      debugPrint('Failed to parse classification response: $e');
      return ClassificationResult(
        category: TopicCategory.daily,
        difficulty: TopicDifficulty.medium,
        tags: [],
      );
    }
  }

  /// ルールベースでの簡易分類（AIが利用できない場合のフォールバック）
  ClassificationResult classifyTopicByRules(String topicText) {
    final lowerText = topicText.toLowerCase();

    // カテゴリ判定
    TopicCategory category = TopicCategory.daily;
    if (_containsAny(lowerText, [
      '社会',
      '政治',
      '経済',
      '環境',
      '教育',
      '医療',
      '法律',
      '制度'
    ])) {
      category = TopicCategory.social;
    } else if (_containsAny(lowerText, [
      '人生',
      '幸せ',
      '価値',
      '信念',
      '哲学',
      '生き方',
      '死',
      '愛',
      '正義'
    ])) {
      category = TopicCategory.value;
    }

    // 難易度判定
    TopicDifficulty difficulty = TopicDifficulty.medium;
    if (_containsAny(lowerText, ['好き', '嫌い', '選ぶなら', 'どっち'])) {
      difficulty = TopicDifficulty.easy;
    } else if (_containsAny(lowerText, [
      'なぜ',
      '理由',
      '考え',
      '意見',
      'どう思う',
      'べき'
    ])) {
      difficulty = TopicDifficulty.hard;
    }

    return ClassificationResult(
      category: category,
      difficulty: difficulty,
      tags: _extractTags(topicText),
    );
  }

  /// 文字列に指定されたキーワードが含まれているかチェック
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// 簡易的なタグ抽出
  List<String> _extractTags(String text) {
    // ここでは簡易的な実装。必要に応じてより高度な処理を追加
    final words = text.split(RegExp(r'[、。？！\s]'));
    return words
        .where((w) => w.length >= 2 && w.length <= 10)
        .take(3)
        .toList();
  }
}
