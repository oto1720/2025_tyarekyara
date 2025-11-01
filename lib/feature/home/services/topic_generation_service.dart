import '../models/topic.dart';
import '../repositories/ai_repository.dart';

/// トピック生成サービス
class TopicGenerationService {
  final AIRepository _aiRepository;

  TopicGenerationService(this._aiRepository);

  /// トピックを生成
  Future<String> generateTopic({
    TopicCategory? category,
    TopicDifficulty? difficulty,
  }) async {
    final prompt = _buildPrompt(category: category, difficulty: difficulty);
    return await _aiRepository.generateText(
      prompt: prompt,
      temperature: 0.8, // 創造性を高めるため高めに設定
      maxTokens: 200,
    );
  }

  /// プロンプトを構築
  String _buildPrompt({
    TopicCategory? category,
    TopicDifficulty? difficulty,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('あなたは議論を促すトピックを生成するアシスタントです。');
    buffer.writeln('以下の条件に従って、1つのトピック（議題）を生成してください。');
    buffer.writeln();
    buffer.writeln('## 条件');
    buffer.writeln('- トピックは簡潔で明確にしてください（1-2文程度）');
    buffer.writeln('- 多様な意見が出やすいテーマを選んでください');
    buffer.writeln('- 議論を促す形式（問いかけ形式など）にしてください');
    buffer.writeln('- 具体的すぎず、抽象的すぎないバランスを取ってください');
    buffer.writeln();

    if (category != null) {
      buffer.writeln('## カテゴリ: ${category.displayName}');
      buffer.writeln('${category.description}');
      buffer.writeln();
    }

    if (difficulty != null) {
      buffer.writeln('## 難易度: ${difficulty.displayName}');
      buffer.writeln('${difficulty.description}');
      buffer.writeln();
    }

    buffer.writeln('## 出力形式');
    buffer.writeln('トピックのみを出力してください。説明や前置きは不要です。');

    return buffer.toString();
  }

  /// 複数のトピックを生成
  Future<List<String>> generateMultipleTopics({
    required int count,
    TopicCategory? category,
    TopicDifficulty? difficulty,
  }) async {
    final topics = <String>[];

    for (int i = 0; i < count; i++) {
      try {
        final topic = await generateTopic(
          category: category,
          difficulty: difficulty,
        );
        topics.add(topic.trim());
      } catch (e) {
        // エラーが発生しても続行
        print('Error generating topic $i: $e');
      }
    }

    return topics;
  }

  /// カテゴリ別にトピックを生成
  Future<Map<TopicCategory, List<String>>> generateByCategories({
    required int countPerCategory,
    TopicDifficulty? difficulty,
  }) async {
    final result = <TopicCategory, List<String>>{};

    for (final category in TopicCategory.values) {
      result[category] = await generateMultipleTopics(
        count: countPerCategory,
        category: category,
        difficulty: difficulty,
      );
    }

    return result;
  }
}
