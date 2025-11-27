import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tyarekyara/core/constants/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/setting_item.dart';
import 'package:url_launcher/url_launcher.dart';

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
            child: const Text(
              'キャンセル',
              style: TextStyle(color: AppColors.textSecondary),
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
            child: const Text(
              'ログアウト',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildProfileImage(BuildContext context, String? iconUrl) {
    print('=== SettingsScreen._buildProfileImage ===');
    print('iconUrl (raw): $iconUrl');

    // 保存済みの画像URLを表示
    if (iconUrl != null && iconUrl.isNotEmpty) {
      // URLをトリム（あらゆる種類の空白文字を除去）
      final cleanUrl = iconUrl.replaceAll(RegExp(r'\s+'), '');
      print('iconUrlが存在 (cleaned): $cleanUrl');
      print('iconUrl length: ${iconUrl.length}, cleanUrl length: ${cleanUrl.length}');

      // アセット画像かネットワーク画像かを判定
      if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
        print('ネットワーク画像として読み込み開始');
        return Image.network(
          cleanUrl,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // ネットワークエラー時はデフォルトアイコンを表示
            print('❌ Settings画像読み込みエラー: $error');
            print('スタックトレース: $stackTrace');
            return Container(
              color: Colors.red[50],
              child: Icon(
                Icons.error_outline,
                size: 24,
                color: Colors.red,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('✅ Settings画像読み込み完了');
              return child;
            }
            final progress = loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null;
            print('Settings画像読み込み中: ${progress != null ? "${(progress * 100).toStringAsFixed(0)}%" : "不明"}');
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress,
                ),
              ),
            );
          },
        );
      } else {
        print('⚠️ iconUrlがhttp/httpsで始まっていません: $cleanUrl');
      }
    } else {
      print('iconUrlが空またはnull');
    }

    // デフォルトアイコン
    print('デフォルトアイコンを表示');
    return Icon(
      Icons.person,
      size: 32,
      color: Theme.of(context).primaryColor,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          '設定',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
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
                    print('⚠️ SettingsScreen: ユーザー情報がnull');
                    return const SizedBox.shrink();
                  }
                  print('=== SettingsScreen: ユーザー情報取得 ===');
                  print('  - nickname: ${user.nickname}');
                  print('  - ageRange: ${user.ageRange}');
                  print('  - region: ${user.region}');
                  print('  - iconUrl: ${user.iconUrl}');
                  return GestureDetector(
                    onTap: () {
                      // ★ プロフィール画面へ遷移
                      context.push('/profile');
                    },
                  child:  Container(
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
                            child: _buildProfileImage(context, user.iconUrl),
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
                icon: Icons.info_outline,
                title: '基本情報',
                subtitle: 'バージョン、利用規約など',
                iconColor: Colors.indigo,
                onTap: () async {
                  // TODO: 基本情報画面へ遷移
                  final uri = Uri.parse('https://critica-s.vercel.app/');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
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