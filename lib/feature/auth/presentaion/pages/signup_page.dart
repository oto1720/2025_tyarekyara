import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_state.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';

class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nicknameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final obscurePassword = useState(true);
    final obscureConfirmPassword = useState(true);

    String? validateNickname(String? value) {
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

    String? validatePassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'パスワードは必須です';
      }
      if (value.length < 6) {
        return 'パスワードは6文字以上で入力してください';
      }
      return null;
    }

    String? validateConfirmPassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'パスワードを確認してください';
      }
      if (value != passwordController.text) {
        return 'パスワードが一致しません';
      }
      return null;
    }

    Future<void> handleSignUp() async {
      if (!formKey.currentState!.validate()) return;

      await ref.read(authControllerProvider.notifier).signUpWithEmail(
            email: emailController.text.trim(),
            password: passwordController.text,
            nickname: nicknameController.text.trim(),
          );
    }

    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        guest: () {},
        authenticated: (user) {
          if(!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('アカウント作成成功')),
          );
          // プロフィール設定画面に遷移
          context.go('/profile-setup');
        },
        unauthenticated: () {},
        error: (message) {
          if(!context.mounted) return;
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
        title: const Text('登録'),
        backgroundColor: Colors.transparent,
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
                const SizedBox(height: 24),
                const Text(
                  '新規アカウント作成',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'フォームに入力して続けてください',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: nicknameController,
                  label: 'ニックネーム',
                  hintText: 'ニックネームを入力',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: validateNickname,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: emailController,
                  label: 'メールアドレス',
                  hintText: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: validateEmail,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: passwordController,
                  label: 'パスワード',
                  hintText: '6文字以上',
                  obscureText: obscurePassword.value,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      obscurePassword.value = !obscurePassword.value;
                    },
                  ),
                  validator: validatePassword,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: confirmPasswordController,
                  label: 'パスワード確認',
                  hintText: 'パスワードを再入力',
                  obscureText: obscureConfirmPassword.value,
                  prefixIcon: const Icon(Icons.lock_outline),
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
                CustomButton(
                  text: '登録',
                  onPressed: handleSignUp,
                  isLoading: authState.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  ),
                ),
                const SizedBox(height: 24),
                // 区切り線
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'または',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),
                // Googleサインインボタン
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: authState.maybeWhen(
                      loading: () => null,
                      orElse: () => () async {
                        await ref.read(authControllerProvider.notifier).signInWithGoogle();
                      },
                    ),
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata, size: 24);
                      },
                    ),
                    label: const Text('Googleで登録'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Apple サインインボタン
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: authState.maybeWhen(
                      loading: () => null,
                      orElse: () => () async {
                        await ref.read(authControllerProvider.notifier).signInWithApple();
                      },
                    ),
                    icon: const Icon(Icons.apple, size: 24, color: Colors.black),
                    label: const Text('Appleで登録'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'すでにアカウントをお持ちですか？',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text(
                        'ログイン',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).continueAsGuest();
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'ゲストで続ける',
                      style: TextStyle(fontSize: 16),
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
