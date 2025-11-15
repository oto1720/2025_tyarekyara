import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'create_test_event.dart';
import '../feature/debate/models/debate_match.dart';
import '../feature/debate/models/debate_event.dart';

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