import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../component/widget/click_button.dart';
import '../../../../core/route/routes.dart';
import '../../../widget/input_field.dart';
import '../sign_in_view_model.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ViewModel의 상태와 컨트롤러를 동기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SignInViewModel>();
      _emailController.addListener(() {
        viewModel.onEmailChanged(_emailController.text);
      });
      _passwordController.addListener(() {
        viewModel.onPasswordChanged(_passwordController.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<SignInViewModel>(
            builder: (context, viewModel, child) {
              final state = viewModel.state;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      '로그인',
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 이메일 입력 필드
                    InputField(
                      label: '이메일',
                      hintText: '이메일을 입력해주세요.',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    // 비밀번호 입력 필드
                    InputField(
                      label: '비밀번호',
                      hintText: '비밀번호를 입력해주세요.',
                      controller: _passwordController,
                      obscureText: state.obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          state.obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          viewModel.togglePasswordVisibility();
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    // 비밀번호 찾기
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          '비밀번호를 잊으셨나요?',
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            context.go(Routes.password);
                          },
                          child: const Text(
                            '이메일 인증',
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // 로그인 버튼
                    ClickButton(
                      buttonText: state.isLoading ? '로그인 중...' : '로그인',
                      onPressed: state.isLoading
                          ? null
                          : () {
                        viewModel.signIn(
                          onSuccess: () {
                            context.go(Routes.main);
                          },
                          onError: _showError,
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    // 회원가입
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '계정이 없으신가요?',
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            context.go('/sign_in/sign_up');
                          },
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}