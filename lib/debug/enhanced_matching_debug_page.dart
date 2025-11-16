import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'entry_comparison_widget.dart';

/// エラーハンドリングを強化したマッチングデバッグページ
class EnhancedMatchingDebugPage extends StatefulWidget {
  const EnhancedMatchingDebugPage({super.key});

  @override
  State<EnhancedMatchingDebugPage> createState() =>
      _EnhancedMatchingDebugPageState();
}

class _EnhancedMatchingDebugPageState
    extends State<EnhancedMatchingDebugPage> {
  final String eventId = 'test_event_001';
  bool isLoading = false;
  String? lastError;
  String? lastSuccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 マッチングデバッグ（強化版）'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showDebugInfo,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // エラー表示
          if (lastError != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          '直前のエラー',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      lastError!,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => lastError = null),
                      icon: const Icon(Icons.close),
                      label: const Text('閉じる'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 成功表示
          if (lastSuccess != null)
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          '直前の成功',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(lastSuccess!),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => lastSuccess = null),
                      icon: const Icon(Icons.close),
                      label: const Text('閉じる'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          _buildSection('1. 準備', [
            _buildButton(
              'テストイベント作成（締切未来）',
              Icons.event,
              Colors.blue,
              _createTestEvent,
            ),
            _buildButton(
              'テストイベント作成（締切過去）',
              Icons.event_available,
              Colors.blueAccent,
              _createTestEventWithPastDeadline,
            ),
            _buildButton(
              'データクリア',
              Icons.delete_sweep,
              Colors.red,
              _clearData,
            ),
          ]),

          const SizedBox(height: 24),

          _buildSection('2. エントリー作成', [
            _buildButton(
              '2人エントリー（1vs1・短）',
              Icons.people,
              Colors.green,
              () => _createSimpleEntries(1),
            ),
            _buildButton(
              '4人エントリー（2vs2・短）',
              Icons.groups,
              Icons.groups,
              () => _createSimpleEntries(4),
            ),
          ]),

          const SizedBox(height: 24),

          _buildSection('3. マッチング実行', [
            _buildButton(
              '手動マッチング実行',
              Icons.play_arrow,
              Colors.purple,
              _triggerManualMatching,
            ),
            _buildButton(
              'イベントステータス更新',
              Icons.update,
              Colors.orange,
              _triggerEventStatusUpdate,
            ),
          ]),

          const SizedBox(height: 24),

          _buildSection('4. 確認', [
            _buildButton(
              'イベント状態確認',
              Icons.event,
              Colors.blue,
              _checkEventStatus,
            ),
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
            _buildButton(
              '📊 詳細比較分析',
              Icons.analytics,
              Colors.deepPurple,
              _showDetailedComparison,
            ),
          ]),

          const SizedBox(height: 24),

          _buildSection('5. イベントステータス更新', [
            _buildButton(
              '手動ステータス更新実行',
              Icons.update,
              Colors.orange,
              _triggerManualEventStatusUpdate,
            ),
            _buildButton(
              'イベントステータス確認',
              Icons.info,
              Colors.cyan,
              _checkEventStatus,
            ),
          ]),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    dynamic color,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color is Color ? color : null,
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
      print('📝 テストイベント作成開始（締切未来）...');

      final firestore = FirebaseFirestore.instance;
      final eventData = {
        'id': eventId,
        'title': 'テストディベート',
        'topic': 'AIは人類に有益か',
        'description': 'マッチングテスト用',
        'status': 'accepting',
        'scheduledAt': Timestamp.fromDate(DateTime.now().add(Duration(hours: 1))),
        'entryDeadline': Timestamp.fromDate(DateTime.now().add(Duration(hours: 1))),
        'availableDurations': ['short', 'medium'],
        'availableFormats': ['oneVsOne', 'twoVsTwo'],
        'currentParticipants': 0,
        'maxParticipants': 100,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await firestore.collection('debate_events').doc(eventId).set(eventData);

      print('✅ イベント作成成功');
      setState(() {
        lastSuccess = '✅ テストイベント作成完了\nID: $eventId\n締切: 1時間後（まだacceptingのまま）';
        lastError = null;
      });
    } catch (e, stack) {
      print('❌ イベント作成失敗: $e');
      print(stack);
      setState(() {
        lastError = '❌ イベント作成エラー\n\n$e';
        lastSuccess = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createTestEventWithPastDeadline() async {
    setState(() => isLoading = true);
    try {
      print('📝 テストイベント作成開始（締切過去）...');

      final firestore = FirebaseFirestore.instance;
      final eventData = {
        'id': eventId,
        'title': 'テストディベート',
        'topic': 'AIは人類に有益か',
        'description': 'マッチングテスト用（締切過去）',
        'status': 'accepting',
        'scheduledAt': Timestamp.fromDate(DateTime.now().add(Duration(minutes: 5))),
        'entryDeadline': Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: -3))),
        'availableDurations': ['short', 'medium'],
        'availableFormats': ['oneVsOne', 'twoVsTwo'],
        'currentParticipants': 0,
        'maxParticipants': 100,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await firestore.collection('debate_events').doc(eventId).set(eventData);

      print('✅ イベント作成成功（締切過去）');
      setState(() {
        lastSuccess = '✅ テストイベント作成完了\nID: $eventId\n締切: 5分前（ステータス更新でmatchingに遷移するはず）';
        lastError = null;
      });
    } catch (e, stack) {
      print('❌ イベント作成失敗: $e');
      print(stack);
      setState(() {
        lastError = '❌ イベント作成エラー\n\n$e';
        lastSuccess = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _clearData() async {
    setState(() => isLoading = true);
    try {
      print('🧹 データクリア開始...');

      final firestore = FirebaseFirestore.instance;

      // エントリー削除
      final entries = await firestore.collection('debate_entries').get();
      for (final doc in entries.docs) {
        await doc.reference.delete();
      }
      print('削除: ${entries.docs.length} エントリー');

      // マッチ削除
      final matches = await firestore.collection('debate_matches').get();
      for (final doc in matches.docs) {
        await doc.reference.delete();
      }
      print('削除: ${matches.docs.length} マッチ');

      print('✅ データクリア完了');
      setState(() {
        lastSuccess = '✅ データクリア完了\n削除: ${entries.docs.length}エントリー + ${matches.docs.length}マッチ';
        lastError = null;
      });
    } catch (e, stack) {
      print('❌ データクリア失敗: $e');
      print(stack);
      setState(() {
        lastError = '❌ データクリアエラー\n\n$e';
        lastSuccess = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createSimpleEntries(int count) async {
    setState(() => isLoading = true);
    try {
      print('📝 $count 人分のエントリー作成開始...');

      final firestore = FirebaseFirestore.instance;
      final format = count == 1 ? 'oneVsOne' : null;

      for (int i = 0; i < count; i++) {
        final userId = 'test_user_${i + 1}';
        final entryId = '${eventId}_$userId';

        String stance;
        if (i % 3 == 0) {
          stance = 'pro';
        } else if (i % 3 == 1) {
          stance = 'con';
        } else {
          stance = 'any';
        }

        final entryData = {
          'userId': userId,
          'eventId': eventId,
          'preferredDuration': 'short',
          'preferredFormat': format,
          'preferredStance': stance,
          'status': 'waiting',
          'enteredAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(seconds: count - i)),
          ),
        };

        await firestore.collection('debate_entries').doc(entryId).set(entryData);

        print('作成: $userId - $stance');
      }

      print('✅ エントリー作成完了');
      setState(() {
        lastSuccess = '✅ $count 件のエントリー作成完了\n形式: $format\n時間: short';
        lastError = null;
      });
    } catch (e, stack) {
      print('❌ エントリー作成失敗: $e');
      print(stack);
      setState(() {
        lastError = '❌ エントリー作成エラー\n\n$e';
        lastSuccess = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _triggerEventStatusUpdate() async {
    setState(() => isLoading = true);
    try {
      print('🔄 イベントステータス更新開始...');

      final functions =
          FirebaseFunctions.instanceFor(region: 'asia-northeast1');

      final result = await functions.httpsCallable('manualEventStatusUpdate').call();

      print('✅ イベントステータス更新完了: ${result.data}');

      setState(() {
        lastSuccess = '✅ イベントステータス更新成功\n\n${result.data}';
        lastError = null;
      });
    } on FirebaseFunctionsException catch (e) {
      print('❌ Firebase Functions エラー発生');
      print('コード: ${e.code}');
      print('メッセージ: ${e.message}');
      print('詳細: ${e.details}');

      setState(() {
        lastError = '❌ イベントステータス更新エラー\n\n'
            'コード: ${e.code}\n'
            'メッセージ: ${e.message}\n'
            '詳細: ${e.details}';
        lastSuccess = null;
      });
    } catch (e, stack) {
      print('❌ 予期しないエラー: $e');
      print(stack);
      setState(() {
        lastError = '❌ イベントステータス更新エラー\n\n$e';
        lastSuccess = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _triggerManualMatching() async {
    setState(() => isLoading = true);
    try {
      print('🎯 マッチング関数呼び出し開始...');

      final functions =
          FirebaseFunctions.instanceFor(region: 'asia-northeast1');

      final result = await functions.httpsCallable('manualMatching').call();

      print('✅ マッチング完了: ${result.data}');

      setState(() {
        lastSuccess = '✅ マッチング成功\n\n${result.data}';
        lastError = null;
      });

      // 結果を自動確認
      await Future.delayed(Duration(milliseconds: 500));
      await _checkMatches();
    } on FirebaseFunctionsException catch (e) {
      print('❌ Firebase Functions エラー発生');
      print('コード: ${e.code}');
      print('メッセージ: ${e.message}');
      print('詳細: ${e.details}');

      String errorMessage = '❌ マッチングエラー\n\n';
      errorMessage += '【エラーコード】\n${e.code}\n\n';
      errorMessage += '【メッセージ】\n${e.message ?? "なし"}\n\n';

      if (e.code == 'failed-precondition') {
        errorMessage += '【原因】\n';
        errorMessage += 'Firestoreインデックスが不足しています。\n';
        errorMessage += 'インデックス作成には数分かかります。\n\n';
        errorMessage += '【解決方法】\n';
        errorMessage += '1. 以下のコマンドを実行:\n';
        errorMessage += '   firebase deploy --only firestore:indexes\n\n';
        errorMessage += '2. 5分待つ\n';
        errorMessage += '3. このボタンを再度押す\n\n';
        errorMessage += '【確認方法】\n';
        errorMessage += 'Firebase Console → Firestore → インデックス\n';
        errorMessage += 'ステータスが「作成中」→「有効」になるまで待つ';
      } else if (e.code == 'unauthenticated') {
        errorMessage += '【原因】認証されていません\n';
        errorMessage += '【解決方法】ログインしてください';
      } else if (e.code == 'permission-denied') {
        errorMessage += '【原因】権限がありません\n';
        errorMessage += '【解決方法】Firestore Rulesを確認';
      } else if (e.code == 'internal') {
        errorMessage += '【原因】Cloud Functions内部エラー\n';
        errorMessage += '【解決方法】\n';
        errorMessage += 'firebase functions:log\n';
        errorMessage += 'でログを確認してください';
      } else {
        errorMessage += '【詳細】\n${e.details}';
      }

      setState(() {
        lastError = errorMessage;
        lastSuccess = null;
      });
    } catch (e, stack) {
      print('❌ 予期しないエラー: $e');
      print(stack);

      String errorMessage = '❌ 予期しないエラー\n\n';
      errorMessage += '$e\n\n';
      errorMessage += '【確認事項】\n';
      errorMessage += '1. Cloud Functionsがデプロイされているか:\n';
      errorMessage += '   firebase functions:list\n\n';
      errorMessage += '2. エミュレータを使用している場合:\n';
      errorMessage += '   useFunctionsEmulator設定を確認\n\n';
      errorMessage += '3. ログ確認:\n';
      errorMessage += '   firebase functions:log';

      setState(() {
        lastError = errorMessage;
        lastSuccess = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkEventStatus() async {
    setState(() => isLoading = true);
    try {
      print('🎪 イベント状態確認...');

      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('debate_events').doc(eventId).get();

      if (!doc.exists) {
        setState(() {
          lastError = '❌ イベントが見つかりません\nID: $eventId';
          lastSuccess = null;
        });
        return;
      }

      final data = doc.data()!;
      final now = DateTime.now();
      final scheduledAt = (data['scheduledAt'] as Timestamp?)?.toDate();
      final entryDeadline = (data['entryDeadline'] as Timestamp?)?.toDate();

      String details = '【イベント状態】\n';
      details += 'ID: $eventId\n';
      details += 'ステータス: ${data['status']}\n';
      details += 'タイトル: ${data['title']}\n\n';

      details += '【時刻情報】\n';
      details += '現在時刻: ${now.toString().substring(0, 19)}\n';
      if (entryDeadline != null) {
        details += '締切時刻: ${entryDeadline.toString().substring(0, 19)}\n';
        final diff = entryDeadline.difference(now);
        if (diff.isNegative) {
          details += '→ 締切から${diff.abs().inMinutes}分経過\n';
        } else {
          details += '→ あと${diff.inMinutes}分で締切\n';
        }
      }
      if (scheduledAt != null) {
        details += '開催時刻: ${scheduledAt.toString().substring(0, 19)}\n';
        final diff = scheduledAt.difference(now);
        if (diff.isNegative) {
          details += '→ 開催から${diff.abs().inMinutes}分経過\n';
        } else {
          details += '→ あと${diff.inMinutes}分で開催\n';
        }
      }

      details += '\n【次に実行されるべき処理】\n';
      if (data['status'] == 'accepting' && entryDeadline != null && now.isAfter(entryDeadline)) {
        details += '⚠️ 締切を過ぎています\n';
        details += '→ イベントステータスを"matching"に更新すべき\n';
      } else if (data['status'] == 'matching' && scheduledAt != null && now.isAfter(scheduledAt)) {
        details += '⚠️ 開催時刻を過ぎています\n';
        details += '→ イベントステータスを"inProgress"に更新すべき\n';
      } else {
        details += '✅ 正常な状態です\n';
      }

      print(details);

      setState(() {
        lastSuccess = details;
        lastError = null;
      });
    } catch (e, stack) {
      print('❌ イベント状態確認失敗: $e');
      print(stack);
      setState(() {
        lastError = '❌ イベント状態確認エラー\n\n$e';
        lastSuccess = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkEntries() async {
    setState(() => isLoading = true);
    try {
      print('📋 エントリー状態確認...');

      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('debate_entries')
          .where('eventId', isEqualTo: eventId)
          .get();

      final waiting =
          snapshot.docs.where((d) => d.data()['status'] == 'waiting').length;
      final matched =
          snapshot.docs.where((d) => d.data()['status'] == 'matched').length;

      String details = '【エントリー状態】\n';
      details += '待機中: $waiting\n';
      details += 'マッチ済: $matched\n';
      details += '合計: ${snapshot.docs.length}\n\n';
      details += '【詳細】\n';

      for (final doc in snapshot.docs) {
        final data = doc.data();
        details += '${data['userId']}: ';
        details += '${data['status']} - ';
        details += '${data['preferredFormat']}/${data['preferredDuration']} ';
        details += '(${data['preferredStance']})\n';
      }

      print(details);

      setState(() {
        lastSuccess = details;
        lastError = null;
      });
    } catch (e, stack) {
      print('❌ エントリー確認失敗: $e');
      print(stack);
      setState(() {
        lastError = '❌ エントリー確認エラー\n\n$e';
        lastSuccess = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkMatches() async {
    setState(() => isLoading = true);
    try {
      print('🏆 マッチ結果確認...');

      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('debate_matches')
          .where('eventId', isEqualTo: eventId)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          lastSuccess = '📭 マッチなし\n\nまだマッチングが成立していません。';
          lastError = null;
        });
        return;
      }

      String details = '【マッチ結果】\n';
      details += '作成数: ${snapshot.docs.length}\n\n';

      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        final proTeam = (data['proTeam'] as Map)['memberIds'] as List;
        final conTeam = (data['conTeam'] as Map)['memberIds'] as List;

        details += '━━━━━━━━━━━━━━━━━━\n';
        details += 'Match ${i + 1} (ID: ${doc.id})\n';
        details += '━━━━━━━━━━━━━━━━━━\n';
        details += '形式: ${data['format']}\n';
        details += '時間: ${data['duration']}\n';
        details += '賛成チーム: ${proTeam.join(", ")}\n';
        details += '反対チーム: ${conTeam.join(", ")}\n';
        details += 'ステータス: ${data['status']}\n';
        details += '\n';
      }

      print(details);

      setState(() {
        lastSuccess = details;
        lastError = null;
      });
    } catch (e, stack) {
      print('❌ マッチ確認失敗: $e');
      print(stack);
      setState(() {
        lastError = '❌ マッチ確認エラー\n\n$e';
        lastSuccess = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showDetailedComparison() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('📊 エントリー詳細比較')),
          body: EntryComparisonWidget(eventId: eventId),
        ),
      ),
    );
  }

  Future<void> _triggerManualEventStatusUpdate() async {
    setState(() => isLoading = true);
    try {
      print('🔄 イベントステータス更新関数呼び出し開始...');

      final functions =
          FirebaseFunctions.instanceFor(region: 'asia-northeast1');

      final result =
          await functions.httpsCallable('manualEventStatusUpdate').call();

      print('✅ ステータス更新完了: ${result.data}');

      setState(() {
        lastSuccess = '✅ イベントステータス更新成功\n\n${result.data}';
        lastError = null;
      });

      // 結果を自動確認
      await Future.delayed(Duration(milliseconds: 500));
      await _checkEventStatus();
    } on FirebaseFunctionsException catch (e) {
      print('❌ Firebase Functions エラー発生');
      print('コード: ${e.code}');
      print('メッセージ: ${e.message}');
      print('詳細: ${e.details}');

      String errorMessage = '❌ ステータス更新エラー\n\n';
      errorMessage += '【エラーコード】\n${e.code}\n\n';
      errorMessage += '【メッセージ】\n${e.message ?? "なし"}\n\n';

      if (e.code == 'unauthenticated') {
        errorMessage += '【原因】認証されていません\n';
        errorMessage += '【解決方法】ログインしてください';
      } else if (e.code == 'permission-denied') {
        errorMessage += '【原因】権限がありません\n';
        errorMessage += '【解決方法】Firestore Rulesを確認';
      } else if (e.code == 'internal') {
        errorMessage += '【原因】Cloud Functions内部エラー\n';
        errorMessage += '【解決方法】\n';
        errorMessage += 'firebase functions:log\n';
        errorMessage += 'でログを確認してください';
      } else {
        errorMessage += '【詳細】\n${e.details}';
      }

      setState(() {
        lastError = errorMessage;
        lastSuccess = null;
      });
    } catch (e, stack) {
      print('❌ 予期しないエラー: $e');
      print(stack);

      String errorMessage = '❌ 予期しないエラー\n\n';
      errorMessage += '$e\n\n';
      errorMessage += '【確認事項】\n';
      errorMessage += '1. Cloud Functionsがデプロイされているか:\n';
      errorMessage += '   firebase functions:list\n\n';
      errorMessage += '2. ログ確認:\n';
      errorMessage += '   firebase functions:log';

      setState(() {
        lastError = errorMessage;
        lastSuccess = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔧 デバッグ情報'),
        content: SingleChildScrollView(
          child: SelectableText(
            '''
【イベントID】
$eventId

【確認コマンド】
# Cloud Functions一覧
firebase functions:list

# ログ確認
firebase functions:log

# Firestore確認
firebase firestore:get debate_entries
firebase firestore:get debate_matches

# インデックス確認
Firebase Console → Firestore → インデックス

【トラブルシューティング】
1. インデックスエラー
   → firebase deploy --only firestore:indexes
   → 5分待つ

2. 認証エラー
   → ログインを確認

3. 関数が見つからない
   → firebase deploy --only functions

4. マッチングされない
   → エントリー数を確認（2人以上必要）
   → format/durationが一致しているか確認
''',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
