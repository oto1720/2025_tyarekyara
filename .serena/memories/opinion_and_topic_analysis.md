# トピック回答と意見投稿の仕組み

## 1. ホーム画面（トピック表示）

### 実装場所
- **ページ**: `lib/feature/home/presentation/pages/daily_topic_home.dart`
- **提供者**: `lib/feature/home/providers/daily_topic_provider.dart`
- **リポジトリ**: `lib/feature/home/repositories/daily_topic_repository.dart`

### ホーム画面の構成
```
DailyTopicHomeScreen
  ├── 今日のトピック（Topic）表示
  ├── 意見入力フォーム
  │   ├── stance選択（賛成・反対・中立）
  │   ├── テキスト入力（100-3000文字）
  │   └── 投稿ボタン
  ├── 意見一覧へのリンク
  └── ニュース表示（HomeAnswerScreen経由）
```

## 2. トピック回答（意見投稿）の仕組み

### データモデル
```dart
// Opinion（意見モデル）
class Opinion {
  String id;                  // 投稿ID（UUID）
  String topicId;            // トピックID
  String topicText;          // トピックのテキスト
  TopicDifficulty? topicDifficulty; // チャレンジ難易度
  String userId;             // 投稿者UID
  String userName;           // 投稿者名
  OpinionStance stance;      // 立場（agree/disagree/neutral）
  String content;            // 意見本文
  DateTime createdAt;        // 投稿日時
  Map<String, int> reactionCounts;    // リアクション数
  Map<String, List<String>> reactedUsers; // リアクションしたユーザー
  bool isDeleted;            // 削除フラグ
}

// OpinionStance（立場）
enum OpinionStance {
  agree,      // 賛成 👍
  disagree,   // 反対 👎
  neutral,    // 中立 🤔
}

// ReactionType（リアクション）
enum ReactionType {
  empathy,          // 共感した 💙
  thoughtful,       // 考えさせられた 💭
  newPerspective,   // 新しい視点 💡
}
```

### 投稿フロー

#### 1. ユーザーが既に投稿しているかチェック
```
OpinionPostState.checkUserOpinion()
  → OpinionRepository.getUserOpinion(topicId, userId)
    → Firestore: opinions コレクション
      WHERE topicId == topicId AND userId == userId AND isDeleted == false
  → hasPosted状態を更新
```

#### 2. 意見を投稿
```
OpinionPostState.postOpinion()
  1. ゲストモード判定（SharedPreferences 'is_guest_mode'）
     - ゲスト: 'guest_' + UUID（複数回投稿可能）
     - 通常: Firebase Authentication UID
  
  2. ユーザー名取得
     - Firestore: users コレクション → nickname フィールド
  
  3. Opinion オブジェクト作成
  
  4. OpinionRepository.postOpinion()
     → Firestore: opinions/{opinionId} に set()
  
  5. 状態更新
     - hasPosted: true
     - userOpinion: Opinion オブジェクト
```

#### 3. 意見を更新（編集）
```
OpinionPostState.updateOpinion()
  → OpinionRepository.updateOpinion()
    → Firestore: opinions/{opinionId} を update()
      - stance フィールド更新
      - content フィールド更新
```

## 3. トピック回答の保存場所

### Firestore スキーマ
```
opinions / {opinionId}
  ├── id: string (UUID)
  ├── topicId: string (トピックID)
  ├── topicText: string (トピック内容)
  ├── topicDifficulty: string (easy/normal/hard) ※チャレンジ用
  ├── userId: string (投稿者UID)
  ├── userName: string (投稿者名)
  ├── stance: string (agree/disagree/neutral)
  ├── content: string (意見本文)
  ├── createdAt: Timestamp
  ├── likeCount: int (default: 0)
  ├── isDeleted: bool (default: false)
  ├── reactionCounts: Map
  │   ├── empathy: int
  │   ├── thoughtful: int
  │   └── newPerspective: int
  └── reactedUsers: Map
      ├── empathy: List<string>
      ├── thoughtful: List<string>
      └── newPerspective: List<string>
```

## 4. 意見一覧の管理

### OpinionListNotifier
```
opinionListProvider.family
  - param: topicId (string)
  - 状態: OpinionListState
    {
      opinions: List<Opinion>,
      isLoading: bool,
      error: string?,
      stanceCounts: Map<OpinionStance, int>
    }
```

### 読み込みロジック
```
OpinionListNotifier.loadOpinions()
  1. Firestore クエリ
     - opinions コレクション
     - WHERE topicId == topicId AND isDeleted == false
     - ソート: createdAt DESC（アプリ側）
  
  2. 立場別集計
     - getOpinionCountsByStance()
     - agree, disagree, neutral の件数
  
  3. 自分の投稿を上部に表示
     - currentUser.uid == opinion.userId を先に追加
     - その後に他のユーザーの投稿
  
  4. 状態更新
```

### リアクション機能
```
OpinionListNotifier.toggleReaction()
  1. 楽観的UI更新（即座にローカル状態更新）
  2. バックグラウンドでFirestoreに反映
     → OpinionRepository.toggleReaction()
  3. エラー時は loadOpinions()で復帰
```

## 5. ユーザーの意見投稿状態の管理

### 状態管理フロー
```
opinionPostProvider
  (NotifierProvider.family<OpinionPostNotifier, OpinionPostState, String>)
  
  - param: topicId
  - 状態フィールド:
    {
      isPosting: bool,           // 投稿中フラグ
      hasPosted: bool,           // 既に投稿したか
      error: string?,            // エラーメッセージ
      userOpinion: Opinion?      // ユーザーの意見オブジェクト
    }
```

### ゲストモード対応
```
SharedPreferences キー: 'is_guest_mode'
  - true: ゲストモード（複数回投稿可能、ユーザーデータなし）
  - false/null: 通常ユーザー（1トピックにつき1回のみ）
```

## 6. 意見詳細・編集画面

### MyOpinionDetailScreen
```
path: /my-opinion/:topicId
  → MyOpinionDetailPage
    → opinionPostProvider(topicId)を監視
    → 自分の投稿を表示・編集可能
```

### 意見一覧画面
```
path: /opinions/:topicId
  → OpinionListScreen
    → opinionListProvider(topicId)を監視
    → 全ユーザーの意見を表示
    → リアクション機能を提供
```
