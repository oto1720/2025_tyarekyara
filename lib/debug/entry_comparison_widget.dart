import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// エントリー詳細比較ウィジェット
class EntryComparisonWidget extends StatefulWidget {
  final String eventId;

  const EntryComparisonWidget({
    super.key,
    required this.eventId,
  });

  @override
  State<EntryComparisonWidget> createState() => _EntryComparisonWidgetState();
}

class _EntryComparisonWidgetState extends State<EntryComparisonWidget> {
  List<Map<String, dynamic>> entries = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('debate_entries')
          .where('eventId', isEqualTo: widget.eventId)
          .get();

      setState(() {
        entries = snapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
        error = null;
      });

      print('📋 読み込んだエントリー数: ${entries.length}');
      for (final entry in entries) {
        print('  - ${entry['userId']}: ${entry['preferredFormat']}/${entry['preferredDuration']} (${entry['preferredStance']}) - ${entry['status']}');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('❌ エントリー読み込みエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('エラー: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEntries,
              child: const Text('再読み込み'),
            ),
          ],
        ),
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('エントリーがありません'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEntries,
              child: const Text('再読み込み'),
            ),
          ],
        ),
      );
    }

    // グループ化して分析
    final groups = _groupEntries(entries);
    final matchableGroups = groups.where((g) => g['canMatch'] == true).toList();
    final unmatchableGroups = groups.where((g) => g['canMatch'] == false).toList();

    return RefreshIndicator(
      onRefresh: _loadEntries,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // サマリー
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 エントリー分析',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('総エントリー数: ${entries.length}'),
                  Text('待機中: ${entries.where((e) => e['status'] == 'waiting').length}'),
                  Text('マッチ済: ${entries.where((e) => e['status'] == 'matched').length}'),
                  const Divider(height: 24),
                  Text(
                    'マッチング可能グループ: ${matchableGroups.length}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'マッチング不可グループ: ${unmatchableGroups.length}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // マッチング可能グループ
          if (matchableGroups.isNotEmpty) ...[
            const Text(
              '✅ マッチング可能',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...matchableGroups.map((group) => _buildGroupCard(group, true)),
            const SizedBox(height: 16),
          ],

          // マッチング不可グループ
          if (unmatchableGroups.isNotEmpty) ...[
            const Text(
              '❌ マッチング不可',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...unmatchableGroups.map((group) => _buildGroupCard(group, false)),
          ],

          // 全エントリー詳細
          const SizedBox(height: 24),
          const Text(
            '📋 全エントリー詳細',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...entries.map(_buildEntryCard),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupEntries(List<Map<String, dynamic>> entries) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    // 待機中のエントリーのみをグループ化
    final waitingEntries = entries.where((e) => e['status'] == 'waiting').toList();

    for (final entry in waitingEntries) {
      final key = '${entry['preferredFormat']}_${entry['preferredDuration']}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(entry);
    }

    // グループごとに分析
    return grouped.entries.map((entry) {
      final key = entry.key;
      final groupEntries = entry.value;
      final parts = key.split('_');
      final format = parts[0];
      final duration = parts[1];

      final teamSize = format == 'oneVsOne' ? 1 : 2;
      final requiredSize = teamSize * 2;

      // 賛成/反対/どちらでも のカウント
      final proCount = groupEntries.where((e) => e['preferredStance'] == 'pro').length;
      final conCount = groupEntries.where((e) => e['preferredStance'] == 'con').length;
      final anyCount = groupEntries.where((e) => e['preferredStance'] == 'any').length;

      // マッチング可能かチェック
      final canFormProTeam = proCount + anyCount >= teamSize;
      final canFormConTeam = conCount + anyCount >= teamSize;
      final hasEnoughTotal = groupEntries.length >= requiredSize;
      final canMatch = canFormProTeam && canFormConTeam && hasEnoughTotal;

      String reason = '';
      if (!hasEnoughTotal) {
        reason = '人数不足 (必要: $requiredSize人、現在: ${groupEntries.length}人)';
      } else if (!canFormProTeam) {
        reason = '賛成チーム構築不可 (pro: $proCount, any: $anyCount, 必要: $teamSize)';
      } else if (!canFormConTeam) {
        reason = '反対チーム構築不可 (con: $conCount, any: $anyCount, 必要: $teamSize)';
      }

      return {
        'format': format,
        'duration': duration,
        'entries': groupEntries,
        'teamSize': teamSize,
        'requiredSize': requiredSize,
        'proCount': proCount,
        'conCount': conCount,
        'anyCount': anyCount,
        'canMatch': canMatch,
        'reason': reason,
      };
    }).toList();
  }

  Widget _buildGroupCard(Map<String, dynamic> group, bool canMatch) {
    final format = group['format'];
    final duration = group['duration'];
    final entries = group['entries'] as List<Map<String, dynamic>>;
    final teamSize = group['teamSize'];
    final requiredSize = group['requiredSize'];
    final proCount = group['proCount'];
    final conCount = group['conCount'];
    final anyCount = group['anyCount'];
    final reason = group['reason'];

    return Card(
      color: canMatch ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  canMatch ? Icons.check_circle : Icons.cancel,
                  color: canMatch ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  '$format / $duration',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('参加者: ${entries.length}人 (必要: $requiredSize人)'),
            Text('チームサイズ: $teamSize人'),
            const Divider(height: 16),
            Text('賛成希望: $proCount人'),
            Text('反対希望: $conCount人'),
            Text('どちらでも: $anyCount人'),
            if (!canMatch && reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '❌ $reason',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Text('参加者:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...entries.map((e) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• ${e['userId']} (${e['preferredStance']})'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final isWaiting = entry['status'] == 'waiting';

    return Card(
      color: isWaiting ? Colors.white : Colors.grey[200],
      child: ListTile(
        leading: Icon(
          isWaiting ? Icons.schedule : Icons.check_circle,
          color: isWaiting ? Colors.orange : Colors.green,
        ),
        title: Text(
          entry['userId'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isWaiting ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('形式: ${entry['preferredFormat']}'),
            Text('時間: ${entry['preferredDuration']}'),
            Text('立場: ${entry['preferredStance']}'),
            Text('状態: ${entry['status']}'),
            if (entry['matchId'] != null) Text('マッチID: ${entry['matchId']}'),
            Text(
              'エントリー時刻: ${_formatTimestamp(entry['enteredAt'])}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: isWaiting
            ? const Chip(
                label: Text('待機中'),
                backgroundColor: Colors.orange,
              )
            : const Chip(
                label: Text('マッチ済'),
                backgroundColor: Colors.green,
              ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '不明';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }
}
