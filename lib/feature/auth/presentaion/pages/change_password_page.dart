import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';

class ChangePasswordPage extends HookConsumerWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final obscureCurrentPassword = useState(true);
    final obscureNewPassword = useState(true);
    final obscureConfirmPassword = useState(true);
    final isLoading = useState(false);

    String? validateCurrentPassword(String? value) {
      if (value == null || value.isEmpty) {
        return '現在のパスワードは必須です';
      }
      return null;
    }

    String? validateNewPassword(String? value) {
      if (value == null || value.isEmpty) {
        return '新しいパスワードは必須です';
      }
      if (value.length < 6) {
        return 'パスワードは6文字以上で入力してください';
      }
      if (value == currentPasswordController.text) {
        return '現在のパスワードと異なるパスワードを入力してください';
      }
      return null;
    }

    String? validateConfirmPassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'パスワード確認は必須です';
      }
      if (value != newPasswordController.text) {
        return 'パスワードが一致しません';
      }
      return null;
    }

    Future<void> handleChangePassword() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        final authRepository = ref.read(authServiceProvider);
        await authRepository.updatePassword(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('パスワードを変更しました'),
            backgroundColor: Colors.green,
          ),
        );

        context.pop();
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (context.mounted) {
          isLoading.value = false;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('パスワード変更'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // アイコン
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'パスワードを変更',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'セキュリティのため、現在のパスワードを入力してから\n新しいパスワードを設定してください',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 現在のパスワード
                CustomTextField(
                  controller: currentPasswordController,
                  label: '現在のパスワード',
                  hintText: '現在のパスワードを入力',
                  obscureText: obscureCurrentPassword.value,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrentPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      obscureCurrentPassword.value = !obscureCurrentPassword.value;
                    },
                  ),
                  validator: validateCurrentPassword,
                ),
                const SizedBox(height: 24),

                // 新しいパスワード
                CustomTextField(
                  controller: newPasswordController,
                  label: '新しいパスワード',
                  hintText: '6文字以上',
                  obscureText: obscureNewPassword.value,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNewPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      obscureNewPassword.value = !obscureNewPassword.value;
                    },
                  ),
                  validator: validateNewPassword,
                ),
                const SizedBox(height: 24),

                // パスワード確認
                CustomTextField(
                  controller: confirmPasswordController,
                  label: '新しいパスワード（確認）',
                  hintText: 'もう一度入力',
                  obscureText: obscureConfirmPassword.value,
                  prefixIcon: const Icon(Icons.lock_clock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      obscureConfirmPassword.value = !obscureConfirmPassword.value;
                    },
                  ),
                  validator: validateConfirmPassword,
                ),
                const SizedBox(height: 40),

                // 変更ボタン
                CustomButton(
                  text: 'パスワードを変更',
                  onPressed: handleChangePassword,
                  isLoading: isLoading.value,
                ),
                const SizedBox(height: 16),

                // キャンセルボタン
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
