import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/terms_providers.dart';

class TermsOfServicePage extends ConsumerStatefulWidget {
  final bool isRequired; // 同意が必須かどうか

  const TermsOfServicePage({
    super.key,
    this.isRequired = false,
  });

  @override
  ConsumerState<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends ConsumerState<TermsOfServicePage> {
  bool _isAccepting = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
        automaticallyImplyLeading: !widget.isRequired, // 必須の場合は戻るボタンを非表示
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '利用規約',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '最終更新日: 2025年12月3日',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    '第1条（適用）',
                    '本規約は、本サービスの提供条件及び本サービスの利用に関する当社とユーザーとの間の権利義務関係を定めることを目的とし、ユーザーと当社との間の本サービスの利用に関わる一切の関係に適用されます。',
                  ),
                  _buildSection(
                    '第2条（禁止事項）',
                    'ユーザーは、本サービスの利用にあたり、以下の行為をしてはなりません。\n\n'
                    '1. 法令または公序良俗に違反する行為\n'
                    '2. 犯罪行為に関連する行為\n'
                    '3. 他のユーザー、第三者、または当社の知的財産権、肖像権、プライバシー、名誉その他の権利または利益を侵害する行為\n'
                    '4. わいせつな表現、差別的表現、暴力的表現など、他人に不快感を与える内容を投稿する行為\n'
                    '5. スパム行為、荒らし行為、嫌がらせ行為\n'
                    '6. 他のユーザーになりすます行為\n'
                    '7. 本サービスのネットワークまたはシステム等に過度な負荷をかける行為\n'
                    '8. 本サービスの運営を妨害するおそれのある行為\n'
                    '9. 不正アクセスをし、またはこれを試みる行為\n'
                    '10. その他、当社が不適切と判断する行為',
                  ),
                  _buildSection(
                    '第3条（ユーザー生成コンテンツ）',
                    'ユーザーは、本サービスを通じて投稿、送信、その他の方法で提供するコンテンツについて、以下の事項に同意するものとします。\n\n'
                    '1. 投稿されたコンテンツに関する一切の責任はユーザーが負うものとします\n'
                    '2. 不適切なコンテンツを投稿した場合、当社は事前の通知なく削除することができます\n'
                    '3. ユーザーは他のユーザーの不適切なコンテンツを報告する義務があります\n'
                    '4. 当社は報告を受けた場合、24時間以内に対応いたします',
                  ),
                  _buildSection(
                    '第4条（利用制限および登録抹消）',
                    '当社は、ユーザーが以下のいずれかに該当する場合には、事前の通知なく、ユーザーに対して、本サービスの全部もしくは一部の利用を制限し、またはユーザーとしての登録を抹消することができるものとします。\n\n'
                    '1. 本規約のいずれかの条項に違反した場合\n'
                    '2. 他のユーザーから複数回の報告を受けた場合\n'
                    '3. その他、当社が本サービスの利用を適当でないと判断した場合',
                  ),
                  _buildSection(
                    '第5条（免責事項）',
                    '当社は、本サービスに関して、ユーザーと他のユーザーまたは第三者との間において生じた取引、連絡または紛争等について一切責任を負いません。',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (widget.isRequired)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isAccepting
                            ? null
                            : () => _acceptTerms(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isAccepting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                '同意して続ける',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isAccepting ? null : () => _declineTerms(context),
                      child: const Text('同意しない'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptTerms(BuildContext context) async {
    setState(() {
      _isAccepting = true;
    });

    try {
      await ref.read(termsRepositoryProvider).acceptTerms(
            ref.read(termsRepositoryProvider).getCurrentUserId()!,
          );

      if (mounted && context.mounted) {
        // ホーム画面に遷移
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  void _declineTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('利用規約への同意が必要です'),
        content: const Text(
          '本サービスを利用するには、利用規約への同意が必要です。'
          '同意しない場合、アプリを終了します。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
          TextButton(
            onPressed: () {
              context.push('/first');
            },
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }
}
