import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tyarekyara/core/constants/app_colors.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';
import 'package:tyarekyara/feature/challenge/services/feedback_service.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';

class ChallengeFeedbackPage extends ConsumerStatefulWidget {
  final Challenge challenge;
  final String challengeAnswer;

  const ChallengeFeedbackPage({
    super.key,
    required this.challenge,
    required this.challengeAnswer,
  });

  @override
  ConsumerState<ChallengeFeedbackPage> createState() =>
      _ChallengeFeedbackPageState();
}

class _ChallengeFeedbackPageState extends ConsumerState<ChallengeFeedbackPage> {
  bool _isLoading = true;
  String? _feedbackText;
  int? _feedbackScore;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateFeedback();
  }

  Future<void> _generateFeedback() async {
    try {
      final feedbackService = ChallengeFeedbackService();
      final result = await feedbackService.generateFeedback(
        topicTitle: widget.challenge.title,
        originalOpinion: widget.challenge.originalOpinionText,
        originalStance: widget.challenge.stance,
        challengeAnswer: widget.challengeAnswer,
      );

      if (mounted) {
        setState(() {
          _feedbackText = result.feedbackText;
          _feedbackScore = result.score;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'フィードバックの生成に失敗しました: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                _buildHeader(),
                const SizedBox(height: 16),

                // チャレンジ概要
                _buildChallengeOverview(),
                const SizedBox(height: 16),

                // ユーザーの回答
                _buildUserAnswer(),
                const SizedBox(height: 16),

                // フィードバック表示
                _buildFeedbackSection(),
                const SizedBox(height: 24),

                // 完了ボタン
                _buildCompleteButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.rate_review_outlined,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'チャレンジ結果',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeOverview() {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shuffle,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.challenge.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                DifficultyBadge(
                  difficulty: widget.challenge.difficulty,
                  showPoints: false,
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.difficultyNormal,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${widget.challenge.difficulty.points}ポイント',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.difficultyNormal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAnswer() {
    return Card(
      color: AppColors.surfaceVariant,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.edit_note,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'あなたの回答（${widget.challenge.stance == Stance.pro ? "反対" : "賛成"}の立場）',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.challengeAnswer,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return _buildFeedbackResult();
  }

  Widget _buildLoadingState() {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: AppColors.border),
      ),
      child: const Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'AIがフィードバックを生成中...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Colors.red),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackResult() {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // スコア表示
            Row(
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AIフィードバック',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                _buildScoreBadge(),
              ],
            ),
            const SizedBox(height: 16),
            // フィードバック本文
            Text(
              _feedbackText ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge() {
    final score = _feedbackScore ?? 0;
    Color backgroundColor;
    Color textColor;

    if (score >= 80) {
      backgroundColor = AppColors.agree.withOpacity(0.2);
      textColor = AppColors.agree;
    } else if (score >= 60) {
      backgroundColor = AppColors.difficultyNormal.withOpacity(0.2);
      textColor = AppColors.difficultyNormal;
    } else if (score >= 40) {
      backgroundColor = AppColors.difficultyHard.withOpacity(0.2);
      textColor = AppColors.difficultyHard;
    } else {
      backgroundColor = AppColors.disagree.withOpacity(0.2);
      textColor = AppColors.disagree;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'スコア: $score',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading
            ? null
            : () {
                // 結果を返して画面を閉じる
                final result = {
                  'points': widget.challenge.difficulty.points,
                  'opinion': widget.challengeAnswer,
                  'feedbackText': _feedbackText,
                  'feedbackScore': _feedbackScore,
                };
                context.pop(result);
              },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline),
            SizedBox(width: 8),
            Text(
              '完了',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
