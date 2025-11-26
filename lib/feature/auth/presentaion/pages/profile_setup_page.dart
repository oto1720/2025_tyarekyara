import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_state.dart';
import '../../providers/profile_setup_provider.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();

  // 年齢オプション
  final List<String> _ageRanges = [
    '10歳未満',
    '10代',
    '20代',
    '30代',
    '40代',
    '50代',
    '60代',
    '70代',
    '80代',
    '90代',
  ];

  // 地域オプション
  final List<String> _regions = [
    '東京都',
    '大阪府',
    '福岡県',
    '熊本県',
    '鹿児島県',
    '沖縄県',
    '北海道',
    '青森県',
    '岩手県',
    '宮城県',
    '秋田県',
    '山形県',
    '福島県',
    '茨城県',
    '栃木県',
    '群馬県',
    '埼玉県',
    '千葉県',
    '神奈川県',
    '新潟県',
    '富山県',
    '石川県',
    '福井県',
    '山梨県',
    '長野県',
    '岐阜県',
    '静岡県',
    '愛知県',
    '三重県',
    '滋賀県',
    '京都府',
    '兵庫県',
    '奈良県',
    '和歌山県',
    '鳥取県',
    '島根県',
    '岡山県',
    '広島県',
    '山口県',
    '徳島県',
    '香川県',
    '愛媛県',
    '高知県',
    '佐賀県',
    '長崎県',
    '大分県',
    '宮崎県',
  ];

  @override
  void initState() {
    super.initState();
    // 初期化は build メソッド内で行う
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  String? _validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return 'ニックネームは必須です';
    }
    if (value.length < 2) {
      return 'ニックネームは2文字以上で入力してください';
    }
    if (value.length > 20) {
      return 'ニックネームは20文字以内で入力してください';
    }
    return null;
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(profileSetupProvider.notifier)
        .saveProfile(nickname: _nicknameController.text.trim());

    if (!success) {
      // エラーは profileSetupProvider の errorMessage で管理される
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final profileSetupState = ref.watch(profileSetupProvider);

    // 現在のユーザー情報でフィールドを初期化
    currentUserAsync.whenData((user) {
      if (user != null && _nicknameController.text.isEmpty) {
        _nicknameController.text = user.nickname;
        // Providerの状態を初期化
        ref.read(profileSetupProvider.notifier).initializeFromUser(
              nickname: user.nickname,
              ageRange: user.ageRange.isNotEmpty ? user.ageRange : null,
              region: user.region.isNotEmpty ? user.region : null,
            );
      }
    });

    // 認証状態の監視
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        guest: () {},
        authenticated: (user) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('プロフィール更新成功')),
          );
          // チュートリアル画面に遷移
          context.go('/home');
        },
        unauthenticated: () {},
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    // プロフィール設定のエラー監視
    ref.listen(profileSetupProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: next.errorMessage!.contains('必須')
                ? Colors.orange
                : Colors.red,
          ),
        );
        ref.read(profileSetupProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('プロフィール設定'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'プロフィール設定',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'プロフィール設定を行ってください',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // プロフィール画像選択
                const Text(
                  'プロフィール画像',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      // 画像プレビュー
                      GestureDetector(
                        onTap: () => ref
                            .read(profileSetupProvider.notifier)
                            .pickImage(),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: profileSetupState.selectedImage != null
                                ? Image.file(
                                    profileSetupState.selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 写真選択ボタン
                      OutlinedButton.icon(
                        onPressed: () => ref
                            .read(profileSetupProvider.notifier)
                            .pickImage(),
                        icon: const Icon(Icons.photo_library),
                        label: Text(
                          profileSetupState.selectedImage != null
                              ? '写真を変更'
                              : '写真を選択',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '※選択しない場合はデフォルト画像が使用されます',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ニックネーム
                CustomTextField(
                  controller: _nicknameController,
                  label: 'ニックネーム',
                  hintText: 'ニックネームを入力',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: _validateNickname,
                ),
                const SizedBox(height: 24),

                // 年齢
                const Text(
                  '年齢',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: profileSetupState.selectedAgeRange,
                      hint: const Text('年齢を選択'),
                      items: _ageRanges.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          ref
                              .read(profileSetupProvider.notifier)
                              .setAgeRange(newValue);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 地域
                const Text(
                  '地域',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: profileSetupState.selectedRegion,
                      hint: const Text('地域を選択'),
                      items: _regions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          ref
                              .read(profileSetupProvider.notifier)
                              .setRegion(newValue);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 保存
                CustomButton(
                  text: '保存',
                  onPressed: _handleSaveProfile,
                  isLoading: profileSetupState.isUploading ||
                      authState.maybeWhen(
                        loading: () => true,
                        orElse: () => false,
                      ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
