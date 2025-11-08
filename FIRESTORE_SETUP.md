# Firestore セキュリティルール設定ガイド

このドキュメントは、Challenge機能のFirebase連携で必要なFirestoreセキュリティルールの設定方法を説明します。

## ⚠️ 重要：セキュリティルールの設定は必須です

Firestoreセキュリティルールが正しく設定されていないと、以下の問題が発生します：

- ❌ データの読み取りができない（`permission-denied`エラー）
- ❌ データの書き込みができない（`permission-denied`エラー）
- ❌ アプリが正常に動作しない

## セキュリティルール設定手順

### 1. Firebase Consoleにアクセス

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. プロジェクトを選択
3. 左メニューから「Firestore Database」を選択
4. 「ルール」タブをクリック

### 2. セキュリティルールをコピー

プロジェクトルートの`firestore.rules`ファイルの内容をコピーしてください。

### 3. Firebase Consoleに貼り付け

1. ルールエディタに`firestore.rules`の内容を貼り付け
2. 「公開」ボタンをクリック
3. 確認ダイアログで「公開」を選択

### 4. 動作確認

アプリを起動して、以下を確認：

```
✅ チャレンジ一覧が表示される
✅ チャレンジを完了できる
✅ 完了したチャレンジの反対意見が表示される
✅ アプリ再起動後もデータが残っている
```

## セキュリティルールの説明

### userChallenges コレクション

```javascript
match /userChallenges/{documentId} {
  // ドキュメントIDの形式: {userId}_{challengeId}

  // 読み取り: 自分のチャレンジのみ
  allow read: if request.auth != null
              && documentId.matches('^' + request.auth.uid + '_.*');

  // 作成・更新: 自分のチャレンジのみ
  allow create, update: if request.auth != null
                        && documentId.matches('^' + request.auth.uid + '_.*')
                        && request.resource.data.userId == request.auth.uid;

  // 削除: 自分のチャレンジのみ
  allow delete: if request.auth != null
                && documentId.matches('^' + request.auth.uid + '_.*')
                && resource.data.userId == request.auth.uid;
}
```

#### ポイント

1. **ドキュメントID形式**: `{userId}_{challengeId}`
   - 例: `abc123_1`, `abc123_2`
   - この形式により、ユーザーごとのチャレンジを管理

2. **認証チェック**: `request.auth != null`
   - ログイン済みユーザーのみアクセス可能

3. **所有者チェック**: `documentId.matches('^' + request.auth.uid + '_.*')`
   - 自分のユーザーIDで始まるドキュメントのみアクセス可能

4. **データ整合性チェック**: `request.resource.data.userId == request.auth.uid`
   - 保存データのuserIdが自分のUIDと一致することを確認

## トラブルシューティング

### エラー: permission-denied

```
❌ [Repository] Firestoreへの書き込み失敗！
   エラー内容: [cloud_firestore/permission-denied] ...
```

#### 原因と対処法

1. **セキュリティルールが設定されていない**
   - 上記の手順でセキュリティルールを設定してください

2. **ユーザーがログインしていない**
   - ログインしているか確認：
     ```
     ✅ [Challenge] ログイン中のユーザーID: abc123
     ```
   - ログインしていない場合は認証機能を確認

3. **ドキュメントIDの形式が間違っている**
   - コンソールログで確認：
     ```
     💾 [Repository] ドキュメントID: abc123_1
     ```
   - `{userId}_{challengeId}`の形式になっているか確認

### エラー: データが保存されない

#### デバッグ方法

1. **コンソールログを確認**
   ```
   📊 [Challenge] completeChallenge() 開始
   ✅ [Challenge] ユーザーID: abc123
   💾 [Repository] saveUserChallenge() 開始
   ✅ [Repository] Firestoreへの書き込み成功！
   ```

2. **Firebase Consoleでデータを確認**
   - Firestore Database → データタブ
   - `userChallenges`コレクションを開く
   - ドキュメントが存在するか確認

3. **セキュリティルールをテスト**
   - Firebase Console → Firestore → ルール → シミュレーター
   - 以下をテスト：
     ```
     場所: /userChallenges/abc123_1
     読み取り/書き込み: 書き込み
     認証: abc123
     ```

### エラー: データが読み込めない

```
🔍 [Repository] getUserChallenges() 開始
   取得したドキュメント数: 0
   ⚪ ドキュメントが見つかりませんでした
```

#### 確認事項

1. **Firestoreにデータが存在するか**
   - Firebase Consoleでデータを確認

2. **ユーザーIDが正しいか**
   - ログで確認：
     ```
     ✅ [Challenge] ログイン中のユーザーID: abc123
     ```

3. **セキュリティルールでクエリが許可されているか**
   - `where('userId', isEqualTo: userId)`が許可されているか確認

## CLIでのセキュリティルール設定（上級者向け）

Firebase CLIを使用してセキュリティルールをデプロイすることもできます。

### 1. Firebase CLIをインストール

```bash
npm install -g firebase-tools
```

### 2. ログイン

```bash
firebase login
```

### 3. プロジェクトを初期化（初回のみ）

```bash
firebase init firestore
```

- `firestore.rules`を選択
- 既存のファイルを使用

### 4. デプロイ

```bash
firebase deploy --only firestore:rules
```

## セキュリティのベストプラクティス

1. **本番環境では厳格なルールを設定**
   - テスト環境以外では`allow read, write: if true;`は絶対に使用しない

2. **ユーザーデータの隔離**
   - ユーザーは自分のデータのみアクセス可能にする
   - 実装済み: `documentId.matches('^' + request.auth.uid + '_.*')`

3. **データ検証**
   - 必須フィールドの存在確認
   - データ型の検証
   - 値の範囲チェック

4. **定期的な監査**
   - Firebase Console → Firestore → 使用状況
   - 異常なアクセスパターンをチェック

## 参考リンク

- [Firestore セキュリティルール 公式ドキュメント](https://firebase.google.com/docs/firestore/security/get-started)
- [セキュリティルールのテスト](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
- [ルールの構文リファレンス](https://firebase.google.com/docs/rules/rules-language)
