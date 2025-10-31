// Stance (賛成/反対) の enum を使うため、challenge_model.dart をインポートします
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';

/// ユーザーの「元の意見」を表すデータモデル
class MyOpinion {
  final String id; // この意見自体のID
  final String challengeId; // どのチャレンジに対する意見か
  final Stance stance; // 賛成か反対か
  final String opinionText; // 意見の本文

  const MyOpinion({
    required this.id,
    required this.challengeId,
    required this.stance,
    required this.opinionText,
  });
}