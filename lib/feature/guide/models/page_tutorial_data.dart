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
        title: '1. トピックを確認',
        description: 'トピックを確認し、関連のニュースも見てみよう',
        imagePath: 'assets/images/tutorial/home/step1.png',
      ),
      TutorialStep(
        title: '2. 意見を投稿',
        description: '賛成・反対・中立の立場を選んで意見を投稿しよう',
        imagePath: 'assets/images/tutorial/home/homestep2.png',
      ),
      TutorialStep(
        title: '3. 他の意見を見る',
        description: '他のユーザーの多様な意見を確認しよう',
        imagePath: 'assets/images/tutorial/home/step3.png',
      ),
      TutorialStep(
        title: '4. チャレンジ機能を行おう',
        description: 'チャレンジ画面で反対の立場で意見を投稿し、AIが判定してくれるよ',
        imagePath: 'assets/images/tutorial/home/homestep4.png',
      ),
      TutorialStep(
        title: '5. ディベートを始める',
        description: 'トピックを投稿するとディベート機能が開放されるので、ディベートにエントリーしよう',
        imagePath: 'assets/images/tutorial/home/homestep5.png',
      ),
    ],
    'statistics': [
      TutorialStep(
        title: '1. 参加統計を確認',
        description: 'あなたの投稿数や参加日数を確認できます',
        imagePath: 'assets/images/tutorial/statistics/toukeistep1.png',
      ),
      TutorialStep(
        title: '2. 多様性スコア',
        description: '様々な立場で意見を投稿するとスコアが上がります',
        imagePath: 'assets/images/tutorial/statistics/toukeistep2.png',
      ),
      TutorialStep(
        title: '3. バッジを集める',
        description: '活動を続けてバッジを獲得しましょう',
        imagePath: 'assets/images/tutorial/statistics/toukeistep3.png',
      ),
    ],
    'challenge': [
      TutorialStep(
        title: '1. チャレンジを選択',
        description: '自分と反対の立場で考えるトレーニングができます',
        imagePath: 'assets/images/tutorial/challenge/tyarestep1.png',
      ),
      TutorialStep(
        title: '2. 意見を考える',
        description: '異なる視点から物事を考える力を養います',
        imagePath: 'assets/images/tutorial/challenge/tyarestep2.png',
      ),
      TutorialStep(
        title: '3. フィードバックを確認',
        description: 'AIからのフィードバックで学びを深めます',
        imagePath: 'assets/images/tutorial/challenge/tyarestep3.png',
      ),
      TutorialStep(
        title: '4. ポイントをゲットしよう',
        description: 'チャレンジを完了するとポイントがゲットでき、バッチを獲得できるよ',
        imagePath: 'assets/images/tutorial/challenge/tyarestep4.png',
      ),
    ],
    'debate': [
      TutorialStep(
        title: '1. イベントを選択',
        description: 'ディベートイベントを選びます.トピック投稿をしないと参加はできません',
        imagePath: 'assets/images/tutorial/debate/dhistep1.png',
      ),
      TutorialStep(
        title: '2. エントリー',
        description: '立場、時間、形式を選んでエントリーしよう',
        imagePath: 'assets/images/tutorial/debate/dhistep2.png',
      ),
      TutorialStep(
        title: '3. 待機画面',
        description: '時間になったら待機画面で対戦相手を待ち、マッチングが成立したらディベート画面に遷移します',
        imagePath: 'assets/images/tutorial/debate/dhistep3.png',
      ),
      TutorialStep(
        title: '4. ディベート',
        description: '対戦相手とリアルタイムで議論を交わし、フェーズを進めていきます',
        imagePath: 'assets/images/tutorial/debate/step3.png',
      ),
      TutorialStep(
        title: '5. AI判定',
        description: 'ディベートを完了するとAIが判定してくれるよ',
        imagePath: 'assets/images/tutorial/debate/step4.png',
      ),
    ],
  };
}
