import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/route/routes.dart';
import 'signup_viewmodel.dart';

/// SignUp Screen - Global Provider 사용
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // main.dart에서 전역 Provider로 설정된 ViewModel 사용
    return const SignUpView();
  }
}

/// SignUp View (StatelessWidget UI)
class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '회원가입',
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
          child: Consumer<SignUpViewModel>(
            builder: (context, viewModel, child) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // 로고 또는 아이콘
                      _buildLogo(),

                      const SizedBox(height: 40),

                      // 이름 입력 필드
                      _buildDisplayNameField(viewModel),

                      const SizedBox(height: 20),

                      // 이메일 입력 필드
                      _buildEmailField(viewModel),

                      const SizedBox(height: 20),

                      // 비밀번호 입력 필드
                      _buildPasswordField(viewModel),

                      const SizedBox(height: 20),

                      // 비밀번호 확인 입력 필드
                      _buildConfirmPasswordField(viewModel),

                      const SizedBox(height: 30),

                      // 약관 동의 체크박스
                      _buildAgreeToTerms(viewModel),

                      const SizedBox(height: 30),

                      // 회원가입 버튼
                      _buildSignUpButton(viewModel),

                      const SizedBox(height: 40),

                      // 로그인 링크
                      _buildSignInLink(),

                      const SizedBox(height: 20),

                      // 에러/성공 메시지
                      _buildMessages(viewModel),
                    ],
                  ),
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
        Icons.person_add,
        size: 80,
        color: Colors.green,
      ),
    );
  }

  Widget _buildDisplayNameField(SignUpViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이름',
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
            border: Border.all(
                color: viewModel.displayNameError != null
                    ? Colors.red
                    : const Color(0xFFCFCFCF),
                width: 1.3
            ),
          ),
          child: TextFormField(
            controller: _displayNameController,
            onChanged: viewModel.onDisplayNameChanged,
            decoration: const InputDecoration(
              hintText: '이름을 입력해주세요',
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
              if (value == null || value.trim().isEmpty) {
                return '이름을 입력해주세요';
              }
              if (value.trim().length < 2) {
                return '이름은 2자 이상이어야 합니다';
              }
              return null;
            },
          ),
        ),
        if (viewModel.displayNameError != null) ...[
          const SizedBox(height: 5),
          Text(
            viewModel.displayNameError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmailField(SignUpViewModel viewModel) {
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
            border: Border.all(
                color: viewModel.emailError != null
                    ? Colors.red
                    : const Color(0xFFCFCFCF),
                width: 1.3
            ),
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
              if (value == null || value.trim().isEmpty) {
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
        if (viewModel.emailError != null) ...[
          const SizedBox(height: 5),
          Text(
            viewModel.emailError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField(SignUpViewModel viewModel) {
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
            border: Border.all(
                color: viewModel.passwordError != null
                    ? Colors.red
                    : const Color(0xFFCFCFCF),
                width: 1.3
            ),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: viewModel.obscurePassword,
            onChanged: viewModel.onPasswordChanged,
            decoration: InputDecoration(
              hintText: '비밀번호를 입력해주세요 (6자 이상)',
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
              if (value.length < 6) {
                return '비밀번호는 6자 이상이어야 합니다';
              }
              return null;
            },
          ),
        ),
        if (viewModel.passwordError != null) ...[
          const SizedBox(height: 5),
          Text(
            viewModel.passwordError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmPasswordField(SignUpViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '비밀번호 확인',
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
            border: Border.all(
                color: viewModel.confirmPasswordError != null
                    ? Colors.red
                    : const Color(0xFFCFCFCF),
                width: 1.3
            ),
          ),
          child: TextFormField(
            controller: _confirmPasswordController,
            obscureText: viewModel.obscurePassword,
            onChanged: viewModel.onConfirmPasswordChanged,
            decoration: const InputDecoration(
              hintText: '비밀번호를 다시 입력해주세요',
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
                return '비밀번호 확인을 입력해주세요';
              }
              if (value != _passwordController.text) {
                return '비밀번호가 일치하지 않습니다';
              }
              return null;
            },
          ),
        ),
        if (viewModel.confirmPasswordError != null) ...[
          const SizedBox(height: 5),
          Text(
            viewModel.confirmPasswordError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAgreeToTerms(SignUpViewModel viewModel) {
    return Row(
      children: [
        Checkbox(
          value: viewModel.agreeToTerms,
          onChanged: (value) => viewModel.toggleAgreeToTerms(),
          activeColor: Colors.blue,
        ),
        const Expanded(
          child: Text(
            '서비스 이용약관 및 개인정보 처리방침에 동의합니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(SignUpViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () => _handleSignUp(viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
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
          '회원가입',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '이미 계정이 있으신가요?',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            context.go(Routes.signIn);
          },
          child: const Text(
            '로그인',
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

  Widget _buildMessages(SignUpViewModel viewModel) {
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

  /// 회원가입 처리
  void _handleSignUp(SignUpViewModel viewModel) async {
    // 폼 유효성 검사
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 회원가입 실행
    await viewModel.signUp();

    // 성공 시 메인 화면으로 이동 (Firebase Auth는 회원가입 시 자동 로그인)
    if (viewModel.hasSuccess && context.mounted) {
      print('🚀 SignUpScreen: 회원가입 성공! 2초 후 메인 화면으로 이동');
      // 2초 후 메인 화면으로 이동 (성공 메시지 보여주기 위해)
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        print('🚀 SignUpScreen: 메인 화면으로 이동 시작');
        context.go(Routes.main);
        print('🚀 SignUpScreen: 메인 화면으로 이동 완료');
      }
    }
  }
}