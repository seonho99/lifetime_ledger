import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/route/routes.dart';
import '../../../domain/usecase/signin_usecase.dart';
import 'signin_viewmodel.dart';

/// SignIn Screen (Provider 설정 + UI)
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // main.dart에서 전역 Provider로 설정된 UseCase를 주입받아 ViewModel 생성
    return ChangeNotifierProvider(
      create: (context) => SignInViewModel(
        signInUseCase: context.read<SignInUseCase>(),
      ),
      child: const SignInView(),
    );
  }
}

/// SignIn View (StatefulWidget UI)
class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '로그인',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<SignInViewModel>(
            builder: (context, viewModel, child) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // 로고 또는 아이콘
                    _buildLogo(),

                    const SizedBox(height: 40),

                    // 이메일 입력 필드
                    _buildEmailField(viewModel),

                    const SizedBox(height: 20),

                    // 비밀번호 입력 필드
                    _buildPasswordField(viewModel),

                    const SizedBox(height: 30),

                    // 비밀번호 찾기
                    _buildForgotPassword(),

                    const SizedBox(height: 30),

                    // 로그인 버튼
                    _buildSignInButton(viewModel),

                    const SizedBox(height: 40),

                    // 회원가입 링크
                    _buildSignUpLink(),

                    const Spacer(),

                    // 에러/성공 메시지
                    _buildMessages(viewModel),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const Center(
      child: Icon(
        Icons.login,
        size: 80,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildEmailField(SignInViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이메일',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCFCFCF), width: 1.3),
          ),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: viewModel.onEmailChanged,
            decoration: const InputDecoration(
              hintText: '이메일을 입력해주세요',
              hintStyle: TextStyle(
                fontFamily: 'Roboto',
                color: Color(0xFFCFCFCF),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return '유효하지 않은 이메일 형식입니다';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(SignInViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '비밀번호',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCFCFCF), width: 1.3),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: viewModel.obscurePassword,
            onChanged: viewModel.onPasswordChanged,
            decoration: InputDecoration(
              hintText: '비밀번호를 입력해주세요',
              hintStyle: const TextStyle(
                fontFamily: 'Roboto',
                color: Color(0xFFCFCFCF),
                fontSize: 16,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: viewModel.togglePasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          '비밀번호를 잊으셨나요?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            context.push(Routes.password);
          },
          child: const Text(
            '비밀번호 재설정',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(SignInViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () => _handleSignIn(viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: viewModel.isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          '로그인',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '계정이 없으신가요?',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            // signUp은 signIn의 하위 라우트이므로 상대 경로 사용
            context.push('/${Routes.signUp}');
          },
          child: const Text(
            '회원가입',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessages(SignInViewModel viewModel) {
    if (viewModel.hasError) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.hasSuccess) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                viewModel.successMessage!,
                style: TextStyle(color: Colors.green.shade700),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 로그인 처리
  void _handleSignIn(SignInViewModel viewModel) async {
    // 폼 유효성 검사
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 로그인 실행
    await viewModel.signIn();

    // 성공 시 메인 화면으로 이동
    if (viewModel.hasSuccess && context.mounted) {
      // GoRouter를 사용하여 메인 화면으로 이동
      context.go(Routes.main);
    }
  }
}