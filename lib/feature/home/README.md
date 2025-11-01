# AIトピック生成機能

AIを活用したトピック（議論のテーマ）自動生成機能です。

## 機能概要

### 1. トピック生成
- **LLM統合**: OpenAI GPT-4 または Anthropic Claude を使用したトピック文の生成
- **プロンプトエンジニアリング**: 高品質なトピックを生成するための最適化されたプロンプト設計
- **カテゴリ別生成**: 以下の3つのカテゴリから選択可能
  - 日常系: 日常生活や身近なテーマについての話題
  - 社会問題系: 社会問題や時事的なテーマについての話題
  - 価値観系: 価値観や人生観についての深いテーマ

### 2. トピック分類器
- **自動分類**: 生成されたトピックを自動的にカテゴリと難易度に分類
- **タグ抽出**: トピックに関連するキーワードを自動抽出
- **ルールベースのフォールバック**: AI分類に失敗した場合の簡易分類機能

### 3. 重複検出
- **類似度計算**: レーベンシュタイン距離とJaccard係数を使用
- **重複防止**: 既存トピックとの類似度をチェック
- **類似度スコア表示**: 開発用に類似度を可視化

### 4. 難易度調整
- **ユーザー層に応じた調整**: 初心者・中級者・上級者向けの難易度配分
- **フィードバック学習**: ユーザーの反応に基づいた難易度の自動調整
- **バランスチェック**: トピックセット全体の難易度バランスを評価

## セットアップ

### 1. APIキーの設定

`.env`ファイルを作成し、APIキーを設定してください：

```bash
# .envファイル（プロジェクトルート）
OPENAI_API_KEY=sk-your-openai-api-key-here
ANTHROPIC_API_KEY=sk-ant-your-anthropic-api-key-here
```

**注意**: `.env`ファイルは`.gitignore`に含まれているため、Gitにコミットされません。

### 2. APIキーの取得方法

#### OpenAI API
1. [OpenAI Platform](https://platform.openai.com/)にアクセス
2. アカウントを作成（または既存アカウントでログイン）
3. [API Keys](https://platform.openai.com/api-keys)ページで新しいAPIキーを作成
4. キーをコピーして`.env`ファイルに設定

#### Anthropic API (Claude)
1. [Anthropic Console](https://console.anthropic.com/)にアクセス
2. アカウントを作成（または既存アカウントでログイン）
3. API Keysセクションで新しいAPIキーを作成
4. キーをコピーして`.env`ファイルに設定

### 3. パッケージのインストール

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 使い方

### 基本的な使い方

1. **ランダム生成**
   - 「ランダムに生成」ボタンをタップすると、AIが自動的にトピックを生成します
   - カテゴリと難易度は自動で判定されます

2. **カテゴリ指定生成**
   - 日常系・社会問題系・価値観系のボタンから選択
   - 選択したカテゴリに適したトピックが生成されます

3. **AIプロバイダーの切り替え**
   - 右上の設定アイコンから OpenAI または Claude を選択可能
   - それぞれの特性に応じたトピック生成が可能

### UIの見方

- **カテゴリバッジ**: トピックのカテゴリを表示（緑=日常系、青=社会問題系、オレンジ=価値観系）
- **難易度バッジ**: トピックの難易度を表示（青緑=簡単、黄色=中程度、赤=難しい）
- **タグ**: トピックに関連するキーワードのリスト
- **類似度スコア**: 既存トピックとの類似度（80%以上で警告表示）

## アーキテクチャ

### ディレクトリ構成

```
lib/feature/home/
├── models/              # データモデル
│   └── topic.dart      # トピックモデル（Freezed使用）
├── repositories/        # 外部API連携
│   └── ai_repository.dart  # OpenAI/Claude API統合
├── services/            # ビジネスロジック
│   ├── topic_generation_service.dart    # トピック生成
│   ├── topic_classifier_service.dart    # トピック分類
│   ├── topic_duplicate_detector.dart    # 重複検出
│   └── topic_difficulty_adjuster.dart   # 難易度調整
├── providers/           # 状態管理（Riverpod）
│   ├── topic_generation_state.dart      # 状態定義
│   └── topic_generation_provider.dart   # プロバイダー
└── presentation/        # UI
    └── pages/
        └── home.dart   # メイン画面
```

### 使用技術

- **状態管理**: Riverpod
- **不変データ**: Freezed
- **HTTP通信**: http パッケージ
- **環境変数**: flutter_dotenv

## トラブルシューティング

### APIエラーが発生する場合

1. `.env`ファイルにAPIキーが正しく設定されているか確認
2. APIキーが有効か確認（課金設定など）
3. インターネット接続を確認
4. API利用制限（レート制限）に達していないか確認

### ビルドエラーが発生する場合

```bash
# キャッシュをクリアして再ビルド
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 重複検出が正しく動作しない場合

- 類似度の閾値を調整: `TopicDuplicateDetector`の`isDuplicate`メソッドの`threshold`パラメータ（デフォルト0.8）

## 今後の拡張案

- [ ] トピック履歴のFirestore保存
- [ ] ユーザー設定の永続化
- [ ] トピックのお気に入り機能
- [ ] トピック生成履歴の表示
- [ ] バッチ生成機能（複数トピックを一括生成）
- [ ] カスタムプロンプト機能
- [ ] トピックの共有機能
- [ ] 多言語対応

## ライセンス

このプロジェクトの一部です。
