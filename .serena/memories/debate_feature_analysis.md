# ディベート機能の実装詳細

## 1. ディベート機能の実装場所とアクセス方法

### 実装場所
- **ページコンポーネント**: `lib/feature/debate/presentation/pages/`
  - `debate_event_list_page.dart` - イベント一覧画面
  - `debate_event_detail_page.dart` - イベント詳細画面
  - `debate_entry_page.dart` - エントリー画面
  - `debate_waiting_room_page.dart` - ウェイティングルーム
  - `debate_room_page.dart` - ディベートルーム
  - `debate_match_detail_page.dart` - マッチ詳細
  - `debate_judgment_waiting_page.dart` - AI判定待機
  - `debate_result_page.dart` - 結果表示
  - `debate_ranking_page.dart` - ランキング
  - `debate_stats_page.dart` - 統計

### アクセスポイント
1. **ボトムナビゲーション**: 「ディベート」タブ（`/debate`）
   - `lib/widgets/bottom_navigation.dart`で定義
   - NavigationItem: `Icons.chat, 'ディベート', '/debate'`

2. **ルーター構設定**: `lib/core/route/app_router.dart`
   - ShellRoute内に`/debate`ルートを登録
   - 複数のサブページ：
     - `/debate` - イベント一覧
     - `/debate/event/:eventId` - イベント詳細
     - `/debate/event/:eventId/entry` - エントリーフォーム
     - `/debate/event/:eventId/waiting` - ウェイティングルーム
     - `/debate/room/:matchId` - ディベートルーム
     - `/debate/judgment/:matchId` - AI判定待機
     - `/debate/result/:matchId` - 結果表示
     - `/debate/ranking` - ランキング
     - `/debate/stats` - 統計

## 2. ディベート関連プロバイダー（状態管理）

### リポジトリレイヤー
- `debate_event_repository.dart` - イベントデータ管理
- `debate_match_repository.dart` - マッチデータ管理
- `debate_room_repository.dart` - ルームデータ管理
- `user_debate_stats_repository.dart` - ユーザー統計管理
- `debate_event_repository.dart` - イベント管理

### プロバイダー
1. **debateEventRepositoryProvider** - EventRepository提供
2. **upcomingEventsProvider** - 開催予定イベント（StreamProvider）
3. **eventDetailProvider** - 特定イベント詳細（StreamProvider.family）
4. **eventListProvider** - イベント一覧（FutureProvider）
5. **completedEventsProvider** - 完了イベント（FutureProvider）
6. **userEntryProvider** - ユーザーのエントリー状態（StreamProvider.family）
7. **currentMatchProvider** - 現在のマッチ（FutureProvider.family）
8. **matchDetailProvider** - マッチ詳細（StreamProvider.family）
9. **matchHistoryProvider** - マッチ履歴（FutureProvider.family）

## 3. ディベートエントリー画面の実装

### DebateEntryPage
- **場所**: `lib/feature/debate/presentation/pages/debate_entry_page.dart`
- **機能**:
  1. イベント情報の表示
  2. エントリーフォーム（EntryForm）
  3. 注意事項の表示
  4. エントリー送信

### エントリーフローム
- **場所**: `lib/feature/debate/presentation/widgets/entry_form.dart`
- **入力項目**:
  - stance（立場選択）
  - format（形式選択）
  - duration（開催時間選択）

### エントリー送信プロセス
```
DebateEntryPage._submitEntry()
  → debateMatchRepositoryProvider.createEntry()
    → Firestore: 'debateEntries' コレクションに保存
    → マッチング処理へ
```

## 4. ディベート状態の管理フロー

### イベント表示フロー
```
debateEventListPage
  → eventListProvider (イベント一覧取得)
    → DebateEventRepository.getUpcomingEvents()
      → Firestore: 'debateEvents' コレクションからクエリ
```

### マッチング・エントリー状態フロー
```
userEntryProvider (ユーザーのエントリー状態監視)
  → DebateMatchRepository.watchUserEntry()
    → Firestore: 'debateEntries' リアルタイム監視
    → (status: submitted, waiting, matched, completed)
```

### マッチ詳細フロー
```
matchDetailProvider (特定マッチの詳細)
  → DebateMatchRepository.watchMatch()
    → Firestore: 'debateMatches' リアルタイム監視
    → messages, judgmentData等を監視
```

## 5. Firestore スキーマ

### 主なコレクション
- `debateEvents` - ディベートイベント定義
- `debateEntries` - ユーザーのエントリー情報
- `debateMatches` - マッチ情報
- `debateMessages` - メッセージログ
- `debateStats` - ユーザー統計

### ドキュメント参照情報
詳細: `lib/feature/debate/FIRESTORE_SCHEMA.md`

## 6. ナビゲーション制御

### リダイレクトロジック
- 認証ページは常にアクセス可能
- **debatePages**: `currentPath.startsWith('/debate/')` で常時アクセス可能
- ゲストモードでもディベートへのアクセスは許可される

### ボトムナビゲーション表示
- ShellRoute内のみボトムナビゲーション表示
- ディベート詳細ページはShellRoute外（ボトムナビなし）
