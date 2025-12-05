import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../providers/profile_edit_provider.dart';
import '../widgets/profile_widgets.dart';

/// 年齢オプション
const List<String> _ageRanges = [
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

/// 地域オプション
const List<String> _regions = [
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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// 画像選択処理
  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        debugPrint('画像選択成功: ${pickedFile.path}');

        // XFileからバイトデータを読み込み、一時ディレクトリに保存
        final bytes = await pickedFile.readAsBytes();
        debugPrint('バイトデータ読み込み成功: ${bytes.length} bytes');

        final tempDir = await getTemporaryDirectory();
        debugPrint('一時ディレクトリ: ${tempDir.path}');

        final fileName =
            'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
        final tempFile = File('${tempDir.path}/$fileName');

        await tempFile.writeAsBytes(bytes);
        debugPrint('一時ファイル作成成功: ${tempFile.path}');

        final exists = await tempFile.exists();
        debugPrint('ファイル存在確認: $exists');

        ref.read(profileEditProvider.notifier).updateSelectedImage(tempFile);

        debugPrint('画像選択処理完了');
      } else {
        debugPrint('画像が選択されませんでした');
      }
    } catch (e, stackTrace) {
      debugPrint('画像選択エラー: $e');
      debugPrint('スタックトレース: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画像の選択に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// プロフィール保存処理
  Future<void> _saveProfile(BuildContext context, WidgetRef ref) async {
    // バリデーション
    final validation = ref.read(profileEditProvider.notifier).validate();
    if (!validation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            validation.nicknameError ??
                validation.currentPasswordError ??
                validation.newPasswordError ??
                validation.confirmPasswordError ??
                '入力内容を確認してください',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 保存処理を実行
    await ref.read(profileSaveProvider.notifier).save();

    // 結果を確認
    final saveState = ref.read(profileSaveProvider);
    if (context.mounted) {
      saveState.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('プロフィールを更新しました'),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
        },
        loading: () {},
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラー: $error'), backgroundColor: Colors.red),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(profileEditProvider);
    // バリデーションは状態を監視してから計算する
    final validation = ref.read(profileEditProvider.notifier).validate();
    final saveState = ref.watch(profileSaveProvider);
    final isLoading = saveState.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'プロフィール編集',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プロフィール画像
              ProfileImageDisplay(
                selectedImage: editState.selectedImage,
                iconUrl: editState.uploadedImageUrl,
                onTap: () {
                  ImagePickerDialog.show(
                    context,
                    onGallery: () =>
                        _pickImage(context, ref, ImageSource.gallery),
                    onCamera: () =>
                        _pickImage(context, ref, ImageSource.camera),
                  );
                },
              ),
              const SizedBox(height: 32),

              // ニックネーム
              const SectionTitle('ニックネーム'),
              const SizedBox(height: 8),
              StandardTextField(
                initialValue: editState.nickname,
                label: 'ニックネーム',
                icon: Icons.person_outline,
                errorText: validation.nicknameError,
                onChanged: (value) {
                  ref.read(profileEditProvider.notifier).updateNickname(value);
                },
              ),
              const SizedBox(height: 24),

              // 年代
              const SectionTitle('年代'),
              const SizedBox(height: 8),
              DropdownField(
                value: editState.ageRange,
                label: '年代を選択',
                icon: Icons.cake_outlined,
                items: _ageRanges,
                onChanged: (value) {
                  ref.read(profileEditProvider.notifier).updateAgeRange(value);
                },
              ),
              const SizedBox(height: 24),

              // 地域
              const SectionTitle('地域'),
              const SizedBox(height: 8),
              DropdownField(
                value: editState.region,
                label: '地域を選択',
                icon: Icons.location_on_outlined,
                items: _regions,
                onChanged: (value) {
                  ref.read(profileEditProvider.notifier).updateRegion(value);
                },
              ),
              const SizedBox(height: 24),

              // パスワード変更セクション
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle('パスワード'),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(profileEditProvider.notifier)
                          .togglePasswordEditing();
                    },
                    child: Text(
                      editState.isEditingPassword ? 'キャンセル' : '変更する',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (editState.isEditingPassword) ...[
                PasswordTextField(
                  initialValue: editState.currentPassword,
                  label: '現在のパスワード',
                  errorText: validation.currentPasswordError,
                  onChanged: (value) {
                    ref
                        .read(profileEditProvider.notifier)
                        .updateCurrentPassword(value);
                  },
                ),
                const SizedBox(height: 16),
                PasswordTextField(
                  initialValue: editState.newPassword,
                  label: '新しいパスワード',
                  errorText: validation.newPasswordError,
                  onChanged: (value) {
                    ref
                        .read(profileEditProvider.notifier)
                        .updateNewPassword(value);
                  },
                ),
                const SizedBox(height: 16),
                PasswordTextField(
                  initialValue: editState.confirmPassword,
                  label: '新しいパスワード（確認）',
                  errorText: validation.confirmPasswordError,
                  onChanged: (value) {
                    ref
                        .read(profileEditProvider.notifier)
                        .updateConfirmPassword(value);
                  },
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        '••••••••',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // 保存ボタン
              SaveButton(
                onPressed: isLoading ? null : () => _saveProfile(context, ref),
                isLoading: isLoading,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
