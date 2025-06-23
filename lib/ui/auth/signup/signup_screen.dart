import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../component/widget/click_button.dart';
import '../../../component/widget/input_field.dart';
import '../../../core/route/routes.dart';
import 'sign_up_view_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  final _defaultImageUrl = 'assets/image/profile.png';

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();
    final isLoading = viewModel.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '회원가입',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                InputField(
                  label: '닉네임',
                  hintText: '닉네임을 입력해주세요.',
                  controller: _nicknameController,
                  onChanged: viewModel.onNicknameChanged,
                ),
                const SizedBox(height: 20),
                InputField(
                  label: '이메일',
                  hintText: '이메일을 입력해주세요.',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: viewModel.onEmailChanged,
                ),
                const SizedBox(height: 20),
                InputField(
                  label: '비밀번호',
                  hintText: '비밀번호를 입력해주세요.',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: viewModel.onPasswordChanged,
                ),
                const SizedBox(height: 20),
                InputField(
                  label: '비밀번호 재확인',
                  hintText: '비밀번호를 다시 입력해주세요.',
                  controller: _confirmPasswordController,
                  onChanged: viewModel.onConfirmPasswordChanged,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                InputField(
                  label: 'ID 입력',
                  hintText: 'ID를 입력해주세요.',
                  controller: _idController,
                  onChanged: viewModel.onIdChanged,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                    ),
                    const Text('회원가입 약관에 동의합니다'),
                  ],
                ),
                const SizedBox(height: 20),
                ClickButton(
                  buttonText: isLoading ? '가입 중...' : '회원가입',
                  onPressed: isLoading
                      ? null
                      : () {
                    if (!_agreeToTerms) {
                      _showError('약관에 동의해주세요.');
                      return;
                    }
                    viewModel.onNicknameChanged(_nicknameController.text.trim());
                    viewModel.onEmailChanged(_emailController.text.trim());
                    viewModel.onPasswordChanged(_passwordController.text.trim());
                    viewModel.onConfirmPasswordChanged(_confirmPasswordController.text.trim());
                    viewModel.onIdChanged(_idController.text.trim());
                    viewModel.signUp(
                      imageUrl: _defaultImageUrl,
                      onSuccess: () {
                        context.go(Routes.signIn);
                      },
                      onError: _showError,

                    );
                  },
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }
}