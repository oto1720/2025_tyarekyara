import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report.dart';
import '../../providers/report_providers.dart';

class ReportDialog extends ConsumerStatefulWidget {
  final String reportedUserId;
  final ReportType type;
  final String contentId;

  const ReportDialog({
    super.key,
    required this.reportedUserId,
    required this.type,
    required this.contentId,
  });

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  ReportReason? _selectedReason;
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String _getReasonText(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return 'スパム';
      case ReportReason.inappropriate:
        return '不適切なコンテンツ';
      case ReportReason.harassment:
        return 'ハラスメント';
      case ReportReason.hateSpeech:
        return 'ヘイトスピーチ';
      case ReportReason.violence:
        return '暴力的な表現';
      case ReportReason.other:
        return 'その他';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportNotifierProvider);

    return AlertDialog(
      title: const Text('報告する'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('報告する理由を選択してください'),
            const SizedBox(height: 16),
            ...ReportReason.values.map((reason) {
              return RadioListTile<ReportReason>(
                title: Text(_getReasonText(reason)),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: '詳細（任意）',
                hintText: '具体的な内容を入力してください',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: reportState.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: reportState.isLoading || _selectedReason == null
              ? null
              : () => _submitReport(context),
          child: reportState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('報告する'),
        ),
      ],
    );
  }

  Future<void> _submitReport(BuildContext context) async {
    if (_selectedReason == null) return;

    await ref.read(reportNotifierProvider.notifier).submitReport(
          reportedUserId: widget.reportedUserId,
          type: widget.type,
          contentId: widget.contentId,
          reason: _selectedReason!,
          details: _detailsController.text.isEmpty ? null : _detailsController.text,
        );

    final state = ref.read(reportNotifierProvider);

    if (context.mounted) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('報告に失敗しました: ${state.error}')),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('報告を送信しました')),
        );
      }
    }
  }
}
