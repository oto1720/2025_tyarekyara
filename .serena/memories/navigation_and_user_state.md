# ナビゲーション構造とユーザー状態管理

## 1. ナビゲーション構造

### メインルーター: `lib/core/route/app_router.dart`

#### 初期化ロジック
```
initialLocation: '/'
redirect: (context, state) async
  - SharedPreferences で状態確認
  - 認証状態、ゲストモード、チュートリアル状態を判定
  - リダイレクト先を決定
```

#### リダイレクトロジック
1. **認証済み + チュートリアル完了**
   - `/first`, `/tutorial` へのアクセス → `/` にリダイレクト
   - その他のページ → そのままアクセス可能

2. **認証済み + チュートリアル未完了**
   - `/tutorial` へ強制リダイレクト

3. **ゲストモード + チュートリアル完了**
   - `/first`, `/tutorial` へのアクセス → `/` にリダイレクト
   - ゲストでもメインアプリへのアクセス可能

4. **未認証 + 非ゲスト + チュートリアル完了**
   - ホーム、設定、統計へのアクセス → `/login` にリダイレクト

5. **未認証 + 非ゲスト + チュートリアル未完了**
   - `/first` へリダイレクト（初回起動画面）

#### 特別なページアクセス
- **認証ページ**: `/login`, `/signup`, `/profile-setup`, `/forgot-password`
  → 常にアクセス可能

- **ディベートページ**: `currentPath.startsWith('/debate/')`
  → 常にアクセス可能

### ルート構成

#### 認証関連（BottomNavigation なし）
```
/first              - 初回起動画面
/tutorial           - チュートリアル画面
/login              - ログインページ
/signup             - サインアップページ
/profile-setup      - プロフィール設定ページ
/profile            - プロフィールページ
/change-password    - パスワード変更ページ
/forgot-password    - パスワードリセット
/notice             - お知らせ画面
```

#### ディベート関連（ShellRoute の外、BottomNavigation なし）
```
/debate/event/:eventId                    - イベント詳細
/debate/event/:eventId/entry              - エントリーページ
/debate/event/:eventId/waiting            - ウェイティングルーム
/debate/room/:matchId                     - ディベートルーム
/debate/match/:matchId                    - マッチ詳細
/debate/judgment/:matchId                 - AI判定待機
/debate/result/:matchId                   - 判定結果
/debate/ranking                           - ランキング
/debate/stats                             - 統計
```

#### チャレンジ関連（ShellRoute の外）
```
/challenge/:challengeId                   - チャレンジ詳細
/challenge/:challengeId/feedback          - チャレンジフィードバック
```

#### メインアプリ（ShellRoute、BottomNavigation あり）
```
/                                         - ホーム（日別トピック）
/opinions/:topicId                        - 意見一覧画面
/my-opinion/:topicId                      - 自分の意見詳細・編集
/statistics                               - 統計画面
/statistics/badges                        - バッジ一覧
/settings                                 - 設定画面
/challenge                                - チャレンジ一覧
/debate                                   - ディベートイベント一覧
```

### ボトムナビゲーション設定

#### `lib/widgets/bottom_navigation.dart`
```dart
navigationItems = [
  NavigationItem(icon: Icons.home, label: 'ホーム', route: '/'),
  NavigationItem(icon: Icons.shuffle, label: 'チャレンジ', route: '/challenge'),
  NavigationItem(icon: Icons.chat, label: 'ディベート', route: '/debate'),
  NavigationItem(icon: Icons.bar_chart, label: '統計', route: '/statistics'),
]
```

#### 選択状態の計算
```
_calculateSelectedIndex(location)
  - /opinions/:topicId, /my-opinion/:topicId → 0 (ホーム)
  - その他は該当するrouteのインデックス
```

#### タップハンドリング
```
_onItemTapped(index)
  → context.go(navigationItems[index].route)
```

## 2. ユーザーの状態管理

### 認証状態

#### AuthState (Freezed)
```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserModel user) = _Authenticated;
  const factory AuthState.error(String message) = _Error;
}
```

#### AuthController (Notifier)
```
authControllerProvider
  (NotifierProvider<AuthController, AuthState>)
  
  状態遷移フロー:
  initial → loading → authenticated / error
```

### ユーザー情報の取得・管理

#### 主要プロバイダー
1. **authStateChangesProvider** (StreamProvider<User?>)
   - Firebase Authentication 状態の監視
   - リアルタイム更新

2. **currentUserProvider** (FutureProvider<UserModel?>)
   - Firestoreからユーザーデータ取得
   - プロフィール情報（nickname等）を含む

3. **authControllerProvider** (NotifierProvider<AuthController, AuthState>)
   - 認証操作を管理
   - サインアップ、サインイン、サインアウト

### ゲストモード管理

#### SharedPreferences キー
```
'is_guest_mode': bool
  - true: ゲストモードで実行中
  - false/null: 通常のユーザーモード
```

#### ゲスト有効化フロー
```
AuthController.continueAsGuest()
  → SharedPreferences.setBool('is_guest_mode', true)
  → チュートリアル完了状態を確認
  → ホームへ遷移
```

#### ゲストデータ扱い
- 意見投稿: 'guest_' + UUID（複数回投稿可能）
- チャレンジ: データ保存なし（ローカルのみ）
- ユーザーデータ: Firestoreに保存されない

### チュートリアル完了状態

#### SharedPreferences キー
```
'tutorial_completed': bool
  - true: チュートリアル完了済み
  - false/null: チュートリアル未完了
```

#### フロー
```
FirstPage → TutorialPage
  ↓
SharedPreferences.setBool('tutorial_completed', true)
  ↓
リダイレクトロジックにより
- 認証済み → ホーム（/）
- ゲスト → ホーム（/）
- 未認証 → ログイン（/login）
```

### ユーザー登録フロー

```
SignUpPage
  ↓
AuthController.signUpWithEmail()
  ├ FirebaseAuth.createUserWithEmailAndPassword()
  ├ Firestore: users/{uid} に UserModel を保存
  │ {
  │   id: uid,
  │   nickname: nickname,
  │   email: email,
  │   createdAt: now,
  │   updatedAt: now
  │ }
  └ SharedPreferences: 'is_guest_mode' をクリア
  ↓
ProfileSetupPage → チュートリアルへ
```

## 3. トピック回答の投稿状態

### OpinionPostProvider
```
opinionPostProvider
  (NotifierProvider.family<OpinionPostNotifier, OpinionPostState, String>)
  
  状態: {
    isPosting: bool,
    hasPosted: bool,
    error: string?,
    userOpinion: Opinion?
  }
```

### 投稿チェックフロー
```
build()
  → checkUserOpinion()
    → OpinionRepository.getUserOpinion(topicId, userId)
      WHERE topicId == topicId AND userId == userId
    → hasPosted を更新
```

### ゲスト対応
```
postOpinion()
  ├ SharedPreferences 'is_guest_mode' チェック
  ├─→ true: guest_UUID として複数回投稿可能
  └─→ false: 通常ユーザーとして1回のみ投稿可能
```

## 4. マッチング・ディベート状態

### ユーザーのエントリー状態
```
userEntryProvider
  (StreamProvider.family<DebateEntry?, (String, String)>)
  
  パラメータ: (eventId, userId)
  状態: DebateEntry? (submitted, waiting, matched, completed)
```

### 現在のマッチ
```
currentMatchProvider
  (FutureProvider.family<DebateMatch?, String>)
  
  パラメータ: userId
  状態: 進行中のマッチ情報
```

### マッチ詳細監視
```
matchDetailProvider
  (StreamProvider.family<DebateMatch?, String>)
  
  パラメータ: matchId
  リアルタイム監視:
  - messages（チャットログ）
  - judgmentData（AI判定結果）
  - status（進行状況）
```
