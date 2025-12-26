import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';

class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final isLoading = useState(false);
    final emailSent = useState(false);

    String? validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return 'メールアドレスは必須です';
      }
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return '有効なメールアドレスを入力してください';
      }
      return null;
    }

    Future<void> handleSendResetEmail() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        final authRepository = ref.read(authServiceProvider);
        await authRepository.sendPasswordResetEmail(emailController.text.trim());

        if (!context.mounted) return;

        emailSent.value = true;
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

    Widget buildFormView() {
      return Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            // アイコン
            Icon(
              Icons.lock_reset,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'パスワードをお忘れですか？',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '登録したメールアドレスを入力してください。\nパスワードリセット用のリンクをお送りします。',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // メールアドレス入力
            CustomTextField(
              controller: emailController,
              label: 'メールアドレス',
              hintText: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: validateEmail,
            ),
            const SizedBox(height: 32),

            // 送信ボタン
            CustomButton(
              text: 'リセットメールを送信',
              onPressed: handleSendResetEmail,
              isLoading: isLoading.value,
            ),
            const SizedBox(height: 16),

            // ログインに戻る
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'ログインに戻る',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildSuccessView() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 60),
          // 成功アイコン
          Icon(
            Icons.mark_email_read,
            size: 100,
            color: Colors.green,
          ),
          const SizedBox(height: 32),
          Text(
            'メールを送信しました',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '${emailController.text} に\nパスワードリセット用のリンクを送信しました。\n\nメールを確認してリンクをクリックし、\n新しいパスワードを設定してください。',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'メールが届かない場合は、迷惑メールフォルダをご確認ください。',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // ログインに戻るボタン
          CustomButton(
            text: 'ログインに戻る',
            onPressed: () => context.go('/login'),
            isLoading: false,
          ),
          const SizedBox(height: 16),

          // 再送信ボタン
          TextButton(
            onPressed: () {
              emailSent.value = false;
            },
            child: Text(
              '別のメールアドレスで再送信',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('パスワードをリセット'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: emailSent.value ? buildSuccessView() : buildFormView(),
        ),
      ),
    );
  }
}
