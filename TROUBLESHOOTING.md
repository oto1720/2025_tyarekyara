# Challenge機能 トラブルシューティングガイド

このガイドでは、Challenge機能のFirebase連携で発生する可能性のある問題と解決方法を説明します。

## 目次

1. [チャレンジが保存されない](#チャレンジが保存されない)
2. [完了済みチャレンジの反対意見が表示されない](#完了済みチャレンジの反対意見が表示されない)
3. [permission-deniedエラー](#permission-deniedエラー)
4. [データが読み込めない](#データが読み込めない)
5. [デバッグ方法](#デバッグ方法)

---

## チャレンジが保存されない

### 症状

- チャレンジを完了しても、反対意見が保存されない
- アプリを再起動すると、完了したチャレンジが未完了に戻る

### 確認手順

#### 1. コンソールログを確認

アプリを起動して、Flutter DevToolsまたはターミナルでログを確認します。

**正常な場合のログ：**
```
✍️ [Challenge] ========== completeChallenge() 開始 ==========
   チャレンジID: 1
   反対意見の文字数: 150文字
   獲得ポイント: 30
✅ [Challenge] ユーザーID: abc123...
✅ [Challenge] 該当チャレンジを発見（インデックス: 0）
✅ [Challenge] 新しいチャレンジオブジェクトを作成
💾 [Challenge] Firestoreに保存開始...
💾 [Repository] ========== saveUserChallenge() 開始 ==========
   ドキュメントID: abc123_1
   保存データ内容:
     - oppositeOpinionText: 週休3日制は...
✅ [Repository] Firestoreへの書き込み成功！
```

**エラーがある場合のログ：**
```
❌ [Challenge] ユーザーがログインしていません。処理を中断します。
```
または
```
❌ [Repository] Firestoreへの書き込み失敗！
   エラー内容: [cloud_firestore/permission-denied]
```

#### 2. ログイン状態を確認

```
✅ [Challenge] ログイン中のユーザーID: abc123...
```

このログが表示されない場合は、ユーザーがログインしていません。

**対処法：**
- アプリで再度ログインする
- 認証機能が正常に動作しているか確認

#### 3. Firestoreセキュリティルールを確認

[FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md)を参照して、セキュリティルールが正しく設定されているか確認してください。

**Firebase Consoleで確認：**
1. Firestore Database → ルール
2. 以下のルールが存在するか確認：
   ```javascript
   match /userChallenges/{documentId} {
     allow create, update: if request.auth != null
                           && documentId.matches('^' + request.auth.uid + '_.*')
                           && request.resource.data.userId == request.auth.uid;
   }
   ```

#### 4. Firestoreにデータが書き込まれているか確認

**Firebase Consoleで確認：**
1. Firestore Database → データ
2. `userChallenges`コレクションを開く
3. ドキュメントIDが`{userId}_{challengeId}`の形式で存在するか確認
4. `oppositeOpinionText`フィールドに値が入っているか確認

---

## 完了済みチャレンジの反対意見が表示されない

### 症状

- チャレンジを完了したが、「完了済み」タブで反対意見が表示されない
- 「（意見が保存されていません）」と表示される

### 確認手順

#### 1. データ読み込みログを確認

アプリ起動時のログを確認します。

**正常な場合：**
```
📊 [Challenge] ========== loadChallenges() 開始 ==========
✅ [Challenge] ログイン中のユーザーID: abc123...
🔍 [Repository] getUserChallenges() 開始
   取得したドキュメント数: 2
   ドキュメント: abc123_1
     - status: completed
     - oppositeOpinionText: あり(150文字)
✅ [Repository] データ取得成功！返却件数: 2
  ✅ ID:1 Firestore完了データあり（30P）
  完了済み: 1件 / 未完了: 3件
```

**問題がある場合：**
```
🔍 [Repository] getUserChallenges() 開始
   取得したドキュメント数: 0
   ⚪ ドキュメントが見つかりませんでした
```

#### 2. Firestoreのデータを直接確認

**Firebase Consoleで確認：**
1. Firestore Database → データ
2. `userChallenges`コレクションを開く
3. 該当ドキュメント（例：`abc123_1`）を開く
4. 以下のフィールドを確認：
   - `oppositeOpinionText`: 反対意見のテキスト
   - `status`: "completed"
   - `earnedPoints`: ポイント数

#### 3. データのマージ処理を確認

```
🔄 [Challenge] データマージ処理開始...
  ダミーデータ数: 4
  ⚪ ID:1 Firestoreにデータなし→ダミーデータ使用（挑戦可能）
```

このログが表示される場合、Firestoreからデータが取得できていません。

**対処法：**
- セキュリティルールを確認
- ログインユーザーIDとドキュメントIDが一致しているか確認
- Firestoreにデータが存在するか確認

#### 4. リフレッシュボタンで再読み込み

画面右上のリフレッシュボタン（🔄）をタップして、データを再読み込みしてください。

---

## permission-deniedエラー

### 症状

```
❌ [Repository] Firestoreへの書き込み失敗！
   エラー内容: [cloud_firestore/permission-denied] Missing or insufficient permissions.
```

### 原因

1. Firestoreセキュリティルールが設定されていない
2. セキュリティルールの設定が間違っている
3. ユーザーがログインしていない

### 解決方法

#### 1. セキュリティルールを設定

[FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md)の手順に従って、セキュリティルールを設定してください。

#### 2. セキュリティルールをテスト

**Firebase Consoleでテスト：**
1. Firestore Database → ルール → シミュレーター
2. 以下を入力：
   - **場所**: `/userChallenges/abc123_1`（自分のユーザーID）
   - **読み取り/書き込み**: 書き込み
   - **認証**: カスタム → `{"uid": "abc123"}`（自分のユーザーID）
3. 「実行」をクリック
4. ✅ が表示されることを確認

#### 3. ルールのデプロイを確認

セキュリティルールを変更した後、必ず「公開」ボタンをクリックしてください。

---

## データが読み込めない

### 症状

- アプリ起動時にチャレンジ一覧が表示されない
- ローディング中のまま動かない

### 確認手順

#### 1. ローディング状態を確認

```dart
final challengeState = ref.watch(challengeProvider);
print('isLoading: ${challengeState.isLoading}');
```

#### 2. エラーログを確認

```
❌ [Challenge] エラー発生！
   エラー内容: ...
   スタックトレース: ...
```

#### 3. ネットワーク接続を確認

- インターネットに接続されているか確認
- Firebaseサービスが利用可能か確認

#### 4. リフレッシュして再試行

画面右上のリフレッシュボタンをタップしてください。

---

## デバッグ方法

### コンソールログの見方

Challenge機能では、詳細なデバッグログを出力しています。

#### ログの種類

| 絵文字 | 意味 |
|--------|------|
| 📊 | 処理開始/終了 |
| ✅ | 成功 |
| ❌ | エラー |
| ⚠️ | 警告 |
| 🔍 | データ取得 |
| 💾 | データ保存 |
| 🔄 | データマージ・更新 |
| ✍️ | チャレンジ完了 |

#### 正常な動作のログフロー

**アプリ起動時：**
```
📊 [Challenge] ========== loadChallenges() 開始 ==========
✅ [Challenge] ログイン中のユーザーID: abc123...
🔍 [Challenge] Firestoreからデータ取得開始...
🔍 [Repository] ========== getUserChallenges() 開始 ==========
   コレクション名: userChallenges
   ユーザーID: abc123...
   取得したドキュメント数: 2
✅ [Repository] データ取得成功！返却件数: 2
🔄 [Challenge] データマージ処理開始...
  ✅ ID:1 Firestore完了データあり（30P）
  完了済み: 1件 / 未完了: 3件
🎉 [Challenge] loadChallenges() 正常終了
```

**チャレンジ完了時：**
```
✍️ [Challenge] ========== completeChallenge() 開始 ==========
   チャレンジID: 1
   反対意見の文字数: 150文字
✅ [Challenge] ユーザーID: abc123...
✅ [Challenge] 該当チャレンジを発見（インデックス: 0）
🔄 [Challenge] ローカル状態を更新（楽観的UI更新）
💾 [Challenge] Firestoreに保存開始...
💾 [Repository] ========== saveUserChallenge() 開始 ==========
   ドキュメントID: abc123_1
✅ [Repository] Firestoreへの書き込み成功！
```

### Flutter DevToolsの使い方

1. アプリをデバッグモードで起動
2. ターミナルに表示されるURLをブラウザで開く
3. 「Logging」タブでログを確認

### Firestore Consoleでのデバッグ

1. Firebase Console → Firestore Database → データ
2. `userChallenges`コレクションを開く
3. ドキュメントの内容を直接確認

**確認項目：**
- ドキュメントIDが`{userId}_{challengeId}`形式か
- `oppositeOpinionText`に値が入っているか
- `status`が"completed"か
- `earnedPoints`に正しい値が入っているか

### よくある問題と対処法

| 問題 | ログ | 対処法 |
|------|------|--------|
| ログインしていない | `⚠️ ユーザーがログインしていません` | ログインする |
| セキュリティルール未設定 | `❌ permission-denied` | [FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md)参照 |
| データが空 | `⚪ ドキュメントが見つかりませんでした` | Firebase Consoleでデータ確認 |
| パースエラー | `❌ ドキュメントのパースに失敗` | データ構造を確認 |

### リフレッシュ機能

画面右上のリフレッシュボタン（🔄）で、Firestoreからデータを再読み込みできます。

**用途：**
- データが表示されない時
- Firebase Consoleでデータを直接変更した後
- エラーから復旧する時

### サポート

問題が解決しない場合は、以下の情報を含めて報告してください：

1. **症状の詳細**
2. **コンソールログ全体**
3. **Firestoreのデータスクリーンショット**
4. **セキュリティルール**
5. **再現手順**

---

## チェックリスト

デバッグ時のチェックリストです。

### 初期設定

- [ ] Firebaseプロジェクトが正しく設定されている
- [ ] `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) が配置されている
- [ ] セキュリティルールが設定されている（[FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md)参照）
- [ ] アプリが正常にビルドできる

### ユーザー認証

- [ ] ユーザーがログインしている
- [ ] ログでユーザーIDが表示される：`✅ ログイン中のユーザーID: abc123...`

### データ保存

- [ ] チャレンジ完了時にログが表示される
- [ ] `✅ Firestoreへの書き込み成功！`が表示される
- [ ] Firebase Consoleで`userChallenges`コレクションにデータが存在する
- [ ] ドキュメントIDが`{userId}_{challengeId}`形式

### データ読み込み

- [ ] アプリ起動時にログが表示される
- [ ] `✅ データ取得成功！`が表示される
- [ ] 完了済みチャレンジ数が正しい
- [ ] 反対意見が表示される

### トラブル発生時

- [ ] コンソールログを確認した
- [ ] リフレッシュボタンを試した
- [ ] Firebase Consoleでデータを確認した
- [ ] セキュリティルールを確認した
- [ ] ユーザーがログインしているか確認した
