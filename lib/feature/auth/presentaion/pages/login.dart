import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_state.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signInWithEmail(
	  email: _emailController.text.trim(),
	  password: _passwordController.text,
	);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      next.when(
	initial: () {},
	loading: () {},
	authenticated: (user) {
	  ScaffoldMessenger.of(context).showSnackBar(
	    const SnackBar(content: Text('Logged in successfully')),
	  );
	  // ���;bkw�
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
	title: const Text('Login'),
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
		const SizedBox(height: 40),
		// ��~_o������
		Icon(
		  Icons.lock_outline,
		  size: 80,
		  color: Theme.of(context).primaryColor,
		),
		const SizedBox(height: 40),
		const Text(
		  'Welcome\nBack',
		  style: TextStyle(
		    fontSize: 28,
		    fontWeight: FontWeight.bold,
		    height: 1.3,
		  ),
		),
		const SizedBox(height: 8),
		Text(
		  'Login to your account',
		  style: TextStyle(
		    fontSize: 16,
		    color: Colors.grey[600],
		  ),
		),
		const SizedBox(height: 40),
		CustomTextField(
		  controller: _emailController,
		  label: 'Email',
		  hintText: 'example@email.com',
		  keyboardType: TextInputType.emailAddress,
		  prefixIcon: const Icon(Icons.email_outlined),
		  validator: _validateEmail,
		),
		const SizedBox(height: 24),
		CustomTextField(
		  controller: _passwordController,
		  label: 'Password',
		  hintText: 'Min 6 characters',
		  obscureText: _obscurePassword,
		  prefixIcon: const Icon(Icons.lock_outline),
		  suffixIcon: IconButton(
		    icon: Icon(
		      _obscurePassword
			  ? Icons.visibility_off_outlined
			  : Icons.visibility_outlined,
		    ),
		    onPressed: () {
		      setState(() {
			_obscurePassword = !_obscurePassword;
		      });
		    },
		  ),
		  validator: _validatePassword,
		),
		const SizedBox(height: 16),

		Align(
		  alignment: Alignment.centerRight,
		  child: TextButton(
		    onPressed: () {

		      ScaffoldMessenger.of(context).showSnackBar(
			const SnackBar(
			  content: Text('Password reset feature coming soon'),
			),
		      );
		    },
		    child: Text(
		      'Forgot Password?',
		      style: TextStyle(
			color: Theme.of(context).primaryColor,
			fontSize: 14,
			fontWeight: FontWeight.w600,
		      ),
		    ),
		  ),
		),
		const SizedBox(height: 24),
		CustomButton(
		  text: 'Login',
		  onPressed: _handleLogin,
		  isLoading: authState.maybeWhen(
		    loading: () => true,
		    orElse: () => false,
		  ),
		),
		const SizedBox(height: 24),
		Row(
		  mainAxisAlignment: MainAxisAlignment.center,
		  children: [
		    Text(
		      "Don't have an account?",
		      style: TextStyle(
			color: Colors.grey[600],
			fontSize: 14,
		      ),
		    ),
		    TextButton(
		      onPressed: () {
			context.push('/signup');
		      },
		      child: const Text(
			'Sign Up',
			style: TextStyle(
			  fontWeight: FontWeight.w600,
			  fontSize: 14,
			),
		      ),
		    ),
		  ],
		),
	      ],
	    ),
	  ),
	),
      ),
    );
  }
}
