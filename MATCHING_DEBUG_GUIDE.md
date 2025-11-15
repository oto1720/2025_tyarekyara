# マッチング機能デバッグガイド

## 方法1: Firebaseエミュレータでローカルテスト

### ステップ1: エミュレータ起動

```bash
# プロジェクトルートで実行
firebase emulators:start --only firestore,functions
```

### ステップ2: Flutterアプリをエミュレータに接続

`lib/main.dart` に以下を追加（デバッグ時のみ）:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔧 エミュレータ接続（デバッグ時のみ有効化）
  if (!kReleaseMode) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instanceFor(region: 'asia-northeast1')
        .useFunctionsEmulator('localhost', 5001);
  }

  runApp(const ProviderScope(child: MyApp()));
}
```

### ステップ3: テストイベント作成スクリプト

`lib/debug/create_test_event.dart` を作成:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../feature/debate/models/debate_event.dart';

Future<void> createTestEvent() async {
  final firestore = FirebaseFirestore.instance;

  final event = DebateEvent(
    id: 'test_event_001',
    title: 'テストディベート',
    topic: 'AIは人類に有益か',
    description: 'マッチングテスト用イベント',
    status: EventStatus.accepting,
    scheduledAt: DateTime.now().add(Duration(hours: 1)),
    entryDeadline: DateTime.now().add(Duration(hours: 1)),
    availableDurations: [
      DebateDuration.short,
      DebateDuration.medium,
    ],
    availableFormats: [
      DebateFormat.oneVsOne,
      DebateFormat.twoVsTwo,
    ],
    currentParticipants: 0,
    maxParticipants: 100,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  await firestore
      .collection('debate_events')
      .doc(event.id)
      .set(DebateEvent.toFirestore(event));

  print('✅ テストイベント作成完了: ${event.id}');
}
```

### ステップ4: テストエントリー作成ヘルパー

`lib/debug/create_test_entries.dart` を作成:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../feature/debate/models/debate_match.dart';

Future<void> createTestEntries({
  required String eventId,
  required int count,
  DebateFormat format = DebateFormat.oneVsOne,
  DebateDuration duration = DebateDuration.short,
}) async {
  final firestore = FirebaseFirestore.instance;

  for (int i = 0; i < count; i++) {
    final userId = 'test_user_${i + 1}';
    final entryId = '${eventId}_$userId';

    // 立場をローテーション: pro, con, any
    DebateStance stance;
    if (i % 3 == 0) {
      stance = DebateStance.pro;
    } else if (i % 3 == 1) {
      stance = DebateStance.con;
    } else {
      stance = DebateStance.any;
    }

    final entry = DebateEntry(
      userId: userId,
      eventId: eventId,
      preferredDuration: duration,
      preferredFormat: format,
      preferredStance: stance,
      status: MatchStatus.waiting,
      enteredAt: DateTime.now().subtract(Duration(seconds: count - i)),
    );

    await firestore
        .collection('debate_entries')
        .doc(entryId)
        .set(DebateEntry.toFirestore(entry));

    print('✅ エントリー作成: User$i - Format:${format.name} Duration:${duration.name} Stance:${stance.name}');
  }

  print('\n📊 合計 $count 件のエントリーを作成しました');
}
```

### ステップ5: デバッグ用画面を作成

`lib/debug/matching_debug_page.dart` を作成:

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'create_test_event.dart';
import 'create_test_entries.dart';
import '../feature/debate/models/debate_match.dart';

class MatchingDebugPage extends StatefulWidget {
  const MatchingDebugPage({super.key});

  @override
  State<MatchingDebugPage> createState() => _MatchingDebugPageState();
}

class _MatchingDebugPageState extends State<MatchingDebugPage> {
  final String eventId = 'test_event_001';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マッチングデバッグ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            '1. 準備',
            [
              _buildButton(
                'テストイベント作成',
                Icons.event,
                Colors.blue,
                _createTestEvent,
              ),
              _buildButton(
                'Firestoreデータクリア',
                Icons.delete_sweep,
                Colors.red,
                _clearData,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '2. エントリー作成',
            [
              _buildButton(
                '2人エントリー（1vs1・短時間）',
                Icons.people,
                Colors.green,
                () => _createEntries(2, DebateFormat.oneVsOne, DebateDuration.short),
              ),
              _buildButton(
                '4人エントリー（2vs2・短時間）',
                Icons.groups,
                Colors.green,
                () => _createEntries(4, DebateFormat.twoVsTwo, DebateDuration.short),
              ),
              _buildButton(
                '5人エントリー（混合）',
                Icons.people_outline,
                Colors.orange,
                _createMixedEntries,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '3. マッチング実行',
            [
              _buildButton(
                '手動マッチング実行',
                Icons.play_arrow,
                Colors.purple,
                _triggerManualMatching,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '4. 確認',
            [
              _buildButton(
                'エントリー状態確認',
                Icons.list,
                Colors.teal,
                _checkEntries,
              ),
              _buildButton(
                'マッチ結果確認',
                Icons.check_circle,
                Colors.indigo,
                _checkMatches,
              ),
            ],
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Future<void> _createTestEvent() async {
    setState(() => isLoading = true);
    try {
      await createTestEvent();
      _showSuccess('テストイベントを作成しました');
    } catch (e) {
      _showError('エラー: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _clearData() async {
    setState(() => isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;

      // エントリー削除
      final entries = await firestore.collection('debate_entries').get();
      for (final doc in entries.docs) {
        await doc.reference.delete();
      }

      // マッチ削除
      final matches = await firestore.collection('debate_matches').get();
      for (final doc in matches.docs) {
        await doc.reference.delete();
      }

      _showSuccess('データをクリアしました');
    } catch (e) {
      _showError('エラー: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createEntries(
    int count,
    DebateFormat format,
    DebateDuration duration,
  ) async {
    setState(() => isLoading = true);
    try {
      await createTestEntries(
        eventId: eventId,
        count: count,
        format: format,
        duration: duration,
      );
      _showSuccess('$count 件のエントリーを作成しました');
    } catch (e) {
      _showError('エラー: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createMixedEntries() async {
    setState(() => isLoading = true);
    try {
      // 2人: 1vs1・短
      await createTestEntries(
        eventId: eventId,
        count: 2,
        format: DebateFormat.oneVsOne,
        duration: DebateDuration.short,
      );

      // 3人: 2vs2・短（マッチング不成立）
      final firestore = FirebaseFirestore.instance;
      for (int i = 2; i < 5; i++) {
        final userId = 'test_user_${i + 1}';
        final entryId = '${eventId}_$userId';

        final entry = DebateEntry(
          userId: userId,
          eventId: eventId,
          preferredDuration: DebateDuration.short,
          preferredFormat: DebateFormat.twoVsTwo,
          preferredStance: DebateStance.any,
          status: MatchStatus.waiting,
          enteredAt: DateTime.now(),
        );

        await firestore
            .collection('debate_entries')
            .doc(entryId)
            .set(DebateEntry.toFirestore(entry));
      }

      _showSuccess('混合エントリーを作成しました\n2人: 1vs1（マッチング成立）\n3人: 2vs2（人数不足）');
    } catch (e) {
      _showError('エラー: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _triggerManualMatching() async {
    setState(() => isLoading = true);
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast1');
      final result = await functions
          .httpsCallable('manualMatching')
          .call();

      _showSuccess('マッチング完了\n${result.data}');
    } catch (e) {
      _showError('エラー: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkEntries() async {
    setState(() => isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('debate_entries')
          .where('eventId', isEqualTo: eventId)
          .get();

      final waiting = snapshot.docs.where((d) => d.data()['status'] == 'waiting').length;
      final matched = snapshot.docs.where((d) => d.data()['status'] == 'matched').length;

      String details = '';
      for (final doc in snapshot.docs) {
        final data = doc.data();
        details += '\n${data['userId']}: ${data['status']} - ${data['preferredFormat']}/${data['preferredDuration']} (${data['preferredStance']})';
      }

      _showSuccess('エントリー状態:\n待機中: $waiting\nマッチ済: $matched$details');
    } catch (e) {
      _showError('エラー: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkMatches() async {
    setState(() => isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('debate_matches')
          .where('eventId', isEqualTo: eventId)
          .get();

      if (snapshot.docs.isEmpty) {
        _showSuccess('マッチなし');
        return;
      }

      String details = '';
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final proTeam = (data['proTeam'] as Map)['memberIds'] as List;
        final conTeam = (data['conTeam'] as Map)['memberIds'] as List;
        details += '\nMatch ${doc.id}:\n';
        details += '  賛成: ${proTeam.join(", ")}\n';
        details += '  反対: ${conTeam.join(", ")}\n';
        details += '  形式: ${data['format']} / ${data['duration']}\n';
      }

      _showSuccess('マッチ結果 (${snapshot.docs.length}件):$details');
    } catch (e) {
      _showError('エラー: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
```

### ステップ6: ルーティングに追加

`lib/core/route/app_router.dart` に追加:

```dart
import '../../debug/matching_debug_page.dart';

// ルート定義に追加
GoRoute(
  path: '/debug/matching',
  builder: (context, state) => const MatchingDebugPage(),
),
```

---

## 方法2: Firebase Consoleで手動テスト

### 1. イベント作成

Firebase Console → Firestore → `debate_events` コレクション:

```json
{
  "id": "test_event_001",
  "title": "テストディベート",
  "topic": "AIは人類に有益か",
  "status": "accepting",
  "availableDurations": ["short", "medium"],
  "availableFormats": ["oneVsOne", "twoVsTwo"],
  "currentParticipants": 0,
  "maxParticipants": 100,
  "scheduledAt": "2025-11-16T10:00:00Z",
  "entryDeadline": "2025-11-16T10:00:00Z",
  "createdAt": "2025-11-15T10:00:00Z",
  "updatedAt": "2025-11-15T10:00:00Z"
}
```

### 2. エントリー作成

`debate_entries` コレクション:

**エントリー1（賛成）:**
```json
{
  "userId": "user_001",
  "eventId": "test_event_001",
  "preferredDuration": "short",
  "preferredFormat": "oneVsOne",
  "preferredStance": "pro",
  "status": "waiting",
  "enteredAt": "2025-11-15T10:00:00Z"
}
```

**エントリー2（反対）:**
```json
{
  "userId": "user_002",
  "eventId": "test_event_001",
  "preferredDuration": "short",
  "preferredFormat": "oneVsOne",
  "preferredStance": "con",
  "status": "waiting",
  "enteredAt": "2025-11-15T10:01:00Z"
}
```

### 3. 手動マッチング実行

```bash
# ターミナルから実行
firebase functions:call manualMatching --region asia-northeast1
```

### 4. 結果確認

Firestore → `debate_matches` コレクションを確認

---

## 方法3: Flutterアプリ内でテスト

デバッグメニューを追加:

```dart
// デバッグビルドのみ表示
if (!kReleaseMode)
  ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, '/debug/matching');
    },
    child: const Text('🔧 マッチングデバッグ'),
  ),
```

---

## デバッグチェックリスト

### ✅ 確認項目

- [ ] イベントのstatusが `accepting` または `matching`
- [ ] エントリーが2件以上存在
- [ ] エントリーのstatusが `waiting`
- [ ] format と duration が一致するエントリーが複数
- [ ] 賛成/反対の人数が揃っている
- [ ] Cloud Functionsがデプロイされている
- [ ] Schedulerが1分ごとに実行されている

### 🐛 よくある問題

| 問題 | 原因 | 解決策 |
|------|------|--------|
| マッチングされない | 人数不足 | 必要人数分のエントリー作成 |
| マッチングされない | format/durationミスマッチ | 同じ設定のエントリー作成 |
| マッチングされない | 立場の偏り | pro/con/anyをバランスよく |
| 関数が実行されない | デプロイ未完了 | `firebase deploy --only functions` |
| エミュレータで動かない | 接続設定なし | `useFirestoreEmulator()` 追加 |

---

## ログ確認方法

### Cloud Functionsログ

```bash
# リアルタイムログ
firebase functions:log --only scheduledMatching

# 最近のログ
firebase functions:log --limit 50
```

### Firestoreクエリ確認

```bash
# 待機中エントリー確認
firebase firestore:get debate_entries \
  --where 'status==waiting'

# マッチ確認
firebase firestore:get debate_matches
```

---

## 期待される動作

1. エントリー作成後、最大1分以内にマッチング
2. `debate_entries` の `status` が `waiting` → `matched`
3. `debate_entries` に `matchId` が設定される
4. `debate_matches` に新規ドキュメント作成
5. Flutterアプリで自動的にマッチ詳細画面に遷移

---

## トラブルシューティング

### マッチングが全く動かない場合

```bash
# 1. Cloud Functionsの状態確認
firebase functions:list

# 2. Schedulerの状態確認
gcloud scheduler jobs list --location asia-northeast1

# 3. 手動実行でテスト
firebase functions:call manualMatching
```

### エミュレータでテストする利点

- ✅ 本番データを汚さない
- ✅ 何度でもやり直せる
- ✅ オフラインで動作
- ✅ ログがすぐ確認できる
- ✅ コストがかからない
