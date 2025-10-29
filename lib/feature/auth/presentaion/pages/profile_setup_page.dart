import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_state.dart';
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

  String? _selectedAgeRange;
  String? _selectedRegion;
  int _selectedIconIndex = 0;

  // アイコンオプション
  final List<String> _iconOptions = [
    'assets/images/avatar1.png',
    'assets/images/avatar2.png',
    'assets/images/avatar3.png',
    'assets/images/avatar4.png',
    'assets/images/avatar5.png',
    'assets/images/avatar6.png',
  ];

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
    '東京都',
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
    '大阪府',
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
    '福岡県',
    '佐賀県',
    '長崎県',
    '熊本県',
    '大分県',
    '宮崎県',
    '鹿児島県',
    '沖縄県',
  ];

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

    if (_selectedAgeRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('年齢は必須です'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('地域は必須です'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // プロフィール更新
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ユーザーが見つかりません'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).updateProfile(
          userId: currentUser.id,
          nickname: _nicknameController.text.trim(),
          ageRange: _selectedAgeRange,
          region: _selectedRegion,
          iconUrl: _iconOptions[_selectedIconIndex],
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    // プロフィール更新
    currentUserAsync.whenData((user) {
      if (user != null && _nicknameController.text.isEmpty) {
        _nicknameController.text = user.nickname;
        if (user.ageRange.isNotEmpty && _selectedAgeRange == null) {
          _selectedAgeRange = user.ageRange;
        }
        if (user.region.isNotEmpty && _selectedRegion == null) {
          _selectedRegion = user.region;
        }
      }
    });

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (user) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('プロフィール更新成功')),
          );
          // ホーム画面に遷移
          context.go('/');
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

                // 年齢
                const Text(
                  '年齢',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _iconOptions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIconIndex = index;
                          });
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedIconIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                              width: _selectedIconIndex == index ? 3 : 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: _selectedIconIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                      );
                    },
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
                      value: _selectedAgeRange,
                      hint: const Text('年齢を選択'),
                      items: _ageRanges.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAgeRange = newValue;
                        });
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
                      value: _selectedRegion,
                      hint: const Text('地域を選択'),
                      items: _regions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRegion = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                  // 保存
                CustomButton(
                  text: '保存',
                  onPressed: _handleSaveProfile,
                  isLoading: authState.maybeWhen(
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
