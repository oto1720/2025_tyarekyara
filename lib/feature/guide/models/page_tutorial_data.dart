// lib/feature/guide/models/page_tutorial_data.dart

/// 各画面のチュートリアルステップを定義
class TutorialStep {
  final String title;
  final String description;
  final String? imagePath; // 画像パス（オプション）

  const TutorialStep({
    required this.title,
    required this.description,
    this.imagePath,
  });
}

/// ページごとのチュートリアルデータを管理
class PageTutorialData {
  static const Map<String, List<TutorialStep>> tutorials = {
    'home': [
      TutorialStep(
        title: '1. トピックを選択',
        description: '気になるトピックをタップして詳細を確認しましょう',
        imagePath: 'assets/images/tutorial/home/step1.png',
      ),
      TutorialStep(
        title: '2. 意見を投稿',
        description: '賛成・反対・中立の立場を選んで意見を投稿できます',
        imagePath: 'assets/images/tutorial/home/step2.png',
      ),
      TutorialStep(
        title: '3. 他の意見を見る',
        description: '他のユーザーの多様な意見を確認できます',
        imagePath: 'assets/images/tutorial/home/step3.png',
      ),
    ],
    'statistics': [
      TutorialStep(
        title: '1. 参加統計を確認',
        description: 'あなたの投稿数や参加日数を確認できます',
        imagePath: 'assets/images/tutorial/statistics/step1.png',
      ),
      TutorialStep(
        title: '2. 多様性スコア',
        description: '様々な立場で意見を投稿するとスコアが上がります',
        imagePath: 'assets/images/tutorial/statistics/step2.png',
      ),
      TutorialStep(
        title: '3. バッジを集める',
        description: '活動を続けてバッジを獲得しましょう',
        imagePath: 'assets/images/tutorial/statistics/step3.png',
      ),
    ],
    'challenge': [
      TutorialStep(
        title: '1. チャレンジを選択',
        description: '自分と反対の立場で考えるトレーニングができます',
        imagePath: 'assets/images/tutorial/challenge/step1.png',
      ),
      TutorialStep(
        title: '2. 意見を考える',
        description: '異なる視点から物事を考える力を養います',
        imagePath: 'assets/images/tutorial/challenge/step2.png',
      ),
      TutorialStep(
        title: '3. フィードバックを確認',
        description: 'AIからのフィードバックで学びを深めます',
        imagePath: 'assets/images/tutorial/challenge/step3.png',
      ),
    ],
    'debate': [
      TutorialStep(
        title: '1. イベントを選択',
        description: '参加したいディベートイベントを選びます',
        imagePath: 'assets/images/tutorial/debate/step1.png',
      ),
      TutorialStep(
        title: '2. エントリー',
        description: '立場を選んでマッチングを待ちます',
        imagePath: 'assets/images/tutorial/debate/step2.png',
      ),
      TutorialStep(
        title: '3. ディベート',
        description: '対戦相手とリアルタイムで議論を交わします',
        imagePath: 'assets/images/tutorial/debate/step3.png',
      ),
    ],
  };
}
