import 'dart:convert';
import 'package:tyarekyara/feature/home/repositories/ai_repository.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';

/// フィードバック生成結果
class FeedbackResult {
  final String feedbackText;
  final int score;

  FeedbackResult({
    required this.feedbackText,
    required this.score,
  });
}

/// チャレンジフィードバック生成サービス
class ChallengeFeedbackService {
  final AIRepository _aiRepository;

  ChallengeFeedbackService({AIRepository? aiRepository})
      : _aiRepository = aiRepository ?? GeminiRepository();

  /// チャレンジ回答に対するフィードバックを生成
  Future<FeedbackResult> generateFeedback({
    required String topicTitle,
    required String originalOpinion,
    required Stance originalStance,
    required String challengeAnswer,
  }) async {
    final prompt = _buildPrompt(
      topicTitle: topicTitle,
      originalOpinion: originalOpinion,
      originalStance: originalStance,
      challengeAnswer: challengeAnswer,
    );

    final response = await _aiRepository.generateText(
      prompt: prompt,
      temperature: 0.7,
      maxTokens: 1000,
    );

    return _parseResponse(response);
  }

  /// プロンプトを構築
  String _buildPrompt({
    required String topicTitle,
    required String originalOpinion,
    required Stance originalStance,
    required String challengeAnswer,
  }) {
    final originalStanceText = originalStance == Stance.pro ? '賛成' : '反対';
    final challengeStanceText = originalStance == Stance.pro ? '反対' : '賛成';

    return '''
あなたは思考力向上をサポートする教育AIです。
ユーザーが「視点交換チャレンジ」に取り組みました。このチャレンジでは、元々持っていた意見とは反対の立場から意見を述べることで、多角的な視点を養います。

【テーマ】
$topicTitle

【ユーザーの元の意見】（$originalStanceText）
$originalOpinion

【チャレンジ回答】（$challengeStanceText の立場で書いた意見）
$challengeAnswer

以下の観点でフィードバックを提供してください：

1. **反対意見としての妥当性**: 元の意見とは異なる立場を適切に表現できているか
2. **説得力**: 主張に根拠や具体例があるか
3. **論理性**: 一貫した論理展開ができているか

以下のJSON形式で回答してください：
{
  "score": <0-100の整数>,
  "goodPoints": "<良かった点を2-3文で>",
  "improvements": "<改善できる点を2-3文で>",
  "advice": "<次回へのアドバイスを1-2文で>"
}

注意：
- 日本語で回答してください
- 励ましの言葉を含めつつ、具体的な改善点も示してください
- scoreは総合評価です（80以上:優秀、60-79:良好、40-59:普通、40未満:要改善）
''';
  }

  /// AIの応答をパース
  FeedbackResult _parseResponse(String response) {
    try {
      // JSONブロックを抽出（```json ... ``` 形式にも対応）
      String jsonStr = response;

      // コードブロックを除去
      final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
      final match = codeBlockRegex.firstMatch(response);
      if (match != null) {
        jsonStr = match.group(1)!;
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      final score = (json['score'] as num).toInt();
      final goodPoints = json['goodPoints'] as String;
      final improvements = json['improvements'] as String;
      final advice = json['advice'] as String;

      final feedbackText = '''
【良かった点】
$goodPoints

【改善できる点】
$improvements

【次回へのアドバイス】
$advice''';

      return FeedbackResult(
        feedbackText: feedbackText,
        score: score,
      );
    } catch (e) {
      // パースに失敗した場合は生のレスポンスを返す
      return FeedbackResult(
        feedbackText: response,
        score: 50,
      );
    }
  }
}
