import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/setting_item.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('本当にログアウトしますか？'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              'ログアウト',
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '設定',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ユーザー情報カード
              currentUserAsync.when(
                data: (user) {
                  if (user == null) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // アイコン
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ユーザー情報
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.nickname,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${user.ageRange} • ${user.region}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // アカウント
              const SettingSection(title: 'アカウント'),
              SettingItem(
                icon: Icons.person_outline,
                title: 'プロフィール',
                subtitle: 'プロフィール情報を編集',
                iconColor: Colors.blue,
                onTap: () {
                  context.push('/profile');
                },
              ),

              // アプリ設定
              const SettingSection(title: 'アプリ設定'),
              SettingItem(
                icon: Icons.notifications_outlined,
                title: '通知',
                subtitle: '通知の設定を変更',
                iconColor: Colors.orange,
                onTap: () {
                  context.push('/notice');
                },
              ),
              SettingItem(
                icon: Icons.palette_outlined,
                title: '表示',
                subtitle: 'テーマやフォントサイズ',
                iconColor: Colors.purple,
                onTap: () {
                  // TODO: 表示設定画面へ遷移
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('表示設定画面（未実装）')),
                  );
                },
              ),
              SettingItem(
                icon: Icons.more_horiz,
                title: 'その他',
                subtitle: 'その他の設定',
                iconColor: Colors.teal,
                onTap: () {
                  // TODO: その他設定画面へ遷移
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('その他設定画面（未実装）')),
                  );
                },
              ),

              // サポート
              const SettingSection(title: 'サポート'),
              SettingItem(
                icon: Icons.help_outline,
                title: 'ヘルプ',
                subtitle: 'よくある質問',
                iconColor: Colors.green,
                onTap: () {
                  // TODO: ヘルプ画面へ遷移
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ヘルプ画面（未実装）')),
                  );
                },
              ),
              SettingItem(
                icon: Icons.info_outline,
                title: '基本情報',
                subtitle: 'バージョン、利用規約など',
                iconColor: Colors.indigo,
                onTap: () {
                  // TODO: 基本情報画面へ遷移
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('基本情報画面（未実装）')),
                  );
                },
              ),

              // アカウント操作
              const SettingSection(title: 'アカウント操作'),
              DangerSettingItem(
                icon: Icons.logout,
                title: 'ログアウト',
                onTap: () => _showLogoutDialog(context, ref),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
