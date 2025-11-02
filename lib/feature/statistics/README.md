
```markdown
# Statistics Feature

`lib/feature/statistics` は、ユーザーの行動や参加状況を可視化する UI と、それを支えるモデル・プロバイダ・リポジトリをまとめたモジュールです。

以下はコンポーネントの概要、データフロー、永続化（ローカルストレージ）に関する実装メモ、導入/利用方法、実装上の注意点です。

---

## 目次
- 概要
- 主要ファイル一覧
- モデル（データ構造）
- Provider / Notifier
- リポジトリ / 永続化（SharedPreferences）
- プレゼンテーション（Widgets / Pages）
- 使い方サンプル
- 注意点 / TODO

---

## 概要
Statistics 機能は以下の指標を扱います:

- ユーザー統計（参加日数・投稿数など）
- ダイバーシティスコア（多様性）
- 立場の分布（賛成/反対など）
- 参加トレンド（日次の参加数推移）

UI は `fl_chart` を使ったグラフ表示を中心に構成され、状態管理は Riverpod を用いています。モデルは Freezed + JsonSerializable で定義され、リポジトリ経由でデータ取得/永続化を行います。

---

## 主要ファイル一覧（抜粋）
- models/
  - `user_statistics.dart` - ユーザーの基本統計
  - `diversity_score.dart` - ダイバーシティスコア
  - `stance_distribution.dart` - 立場分布
  - `participation_trend.dart` - 日別参加推移

- providers/
  - `statistics_provider.dart` - `StatisticsNotifier`（状態管理、ロード処理）

- repositories/
  - `local_statistics_repository.dart` - SharedPreferences を使ったローカル実装
  - （将来的に `firestore` 等のリポジトリを追加）

- presentation/
  - `pages/statistic.dart` - 統合ページ
  - `widgets/` - 各種カード・グラフコンポーネント

---

## モデル（要点）
- `UserStatistics`
  - userId, participationDays, totalOpinions, consecutiveDays, lastParticipation, createdAt, updatedAt
- `DiversityScore`
  - userId, score (double), breakdown (Map<String,double>), createdAt, updatedAt
- `StanceDistribution`
  - userId, counts (Map<String,int>), total, createdAt, updatedAt
- `ParticipationTrend`
  - userId, points: List<ParticipationPoint(date, count)>, createdAt, updatedAt

（モデルは Freezed + JsonSerializable で定義されており、対応する `*.freezed.dart` / `*.g.dart` が生成されています）

---

## Provider / Notifier
- `statisticsNotifierProvider`（`StatisticsNotifier`）が統計データのロード・更新を担当します。
- 現在は `LocalStatisticsRepository` を使うコードパスが存在し、必要に応じて別実装（Firestore/REST 等）に差し替え可能です。

使用例:

```dart
// ロード（例）
await ref.read(statisticsNotifierProvider.notifier).loadUserStatistics(userId);
```

---

## リポジトリ / 永続化（SharedPreferences）

### 現在の実装概要
- 永続化ライブラリ: `shared_preferences`（`pubspec.yaml` に依存あり）
- 実装ファイル: `lib/feature/statistics/repositories/local_statistics_repository.dart`
- 保存形式: 各モデルを `toJson()` → `jsonEncode` して `SharedPreferences.setString(key, json)` で保存、読み出しは `getString` → `jsonDecode` → `fromJson`。

### 保存キー（ユーザー単位）
- `statistics:user:$userId` — `UserStatistics` の JSON
- `statistics:diversity:$userId` — `DiversityScore` の JSON
- `statistics:stance:$userId` — `StanceDistribution` の JSON
- `statistics:trend:$userId` — `ParticipationTrend` の JSON

### 実装上の挙動（要点）
- 読み取り: データが存在しない場合は `null` を返す。JSON パース失敗時も `null` を返している（例外を握り潰す実装）。
- 書き込み: `setString` を呼ぶが戻り値（保存成功の bool）は現実装でチェックしていない。
- `saveAll(...)` メソッドは個別の save を順に呼ぶのみで、トランザクション的な原子性は無い（ベストエフォート）。

---

## プレゼンテーション（Widgets / Pages）
- `pages/statistic.dart` が統合ページ。起動時に Provider を通じてデータロードを行います。
- 各種カード・グラフは `presentation/widgets/` にまとまっています（`participation_trend_card.dart`, `stance_distribution_card.dart`, `diversity_score_card.dart` 等）。

---

## 使い方（簡易サンプル）

ページを表示して Provider 経由でロードする最小例:

```dart
// ページ遷移で表示
Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StatisticPage()));

// Provider を直接呼ぶ
await ref.read(statisticsNotifierProvider.notifier).loadUserStatistics('user_123');
```

ローカルから直接取得する例:

```dart
final repo = LocalStatisticsRepository();
final stats = await repo.fetchUserStatistics('user_123');
if (stats != null) {
  // 表示処理
}
```

---

## テスト
- 推奨: `LocalStatisticsRepository` の保存→読み出しテストを追加する（正常系 + 破損 JSON の場合）。

単体テスト例（方針）:

1. モック SharedPreferences を使って `saveUserStatistics` が正しく put するか確認
2. 破損した JSON を用意して `fetchUserStatistics` が `null` を返すか確認

※ 既存プロジェクトのテスト方針に合わせて Provider のテストも追加してください。

---

## 注意点 / TODO
- `saveAll` の原子性の改善（短期で戻り値チェック・ログ追加、または一括キーへの移行）
- 大規模データや高頻度更新が発生する場合はローカル DB を検討すること
- モデル変更時は `build_runner` の再実行が必要: `flutter pub run build_runner build --delete-conflicting-outputs`

---

## 参考
- `shared_preferences` package — https://pub.dev/packages/shared_preferences
- `fl_chart` — https://pub.dev/packages/fl_chart
- Riverpod docs — https://riverpod.dev/

---