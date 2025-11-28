# tyarekyara プロジェクト概要

## プロジェクトの目的
Flutterアプリケーション。ユーザーが日々のトピックに対して意見を投稿し、他のユーザーと議論を交わすことで、多角的な思考力を育むアプリケーション。

## 主な機能
1. **ホーム機能**: 日替わりトピックの表示、意見投稿（賛成・反対・中立）、リアクション機能
2. **チャレンジ機能**: 自分と反対の立場で意見を考えるトレーニング、Firebaseで進行状況を永続化
3. **統計機能**: 参加統計、立場別分布、多様性スコア、バッジ
4. **設定機能**: プロフィール編集、通知設定、テーマ設定

## 技術スタック
- **言語/フレームワーク**: Flutter (Dart)
- **状態管理**: Riverpod 2.x
- **バックエンド**: Firebase (Authentication, Cloud Firestore, Storage, Cloud Messaging)
- **ルーティング**: go_router
- **その他**: freezed, json_serializable

## コードスタイル
- Dartのコード規約に従う
- イミュータブルなデータクラス（freezedを使用）
- JSONシリアライズ対応（json_serializableを使用）
- レイヤードアーキテクチャ（Presentation, Provider, Repository, Model, Service）

## プロジェクト構造
```
lib/
├── feature/
│   ├── auth/          # 認証機能
│   ├── home/          # ホーム・トピック機能
│   ├── challenge/     # チャレンジ機能
│   ├── statistics/    # 統計機能
│   └── settings/      # 設定機能
├── router/            # ルーティング設定
├── utils/             # ユーティリティ
└── widgets/           # 共通ウィジェット
```
