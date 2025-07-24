import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_status/component/widget/click_button.dart';
import 'package:share_status/core/route/routes.dart';

import '../../widget/input_field.dart';
import 'password_reset_view_model.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ViewModel의 상태와 컨트롤러를 동기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<PasswordResetViewModel>();
      _emailController.addListener(() {
        viewModel.onEmailChanged(_emailController.text);
      });

      // 화면에 진입할 때마다 상태 초기화
      viewModel.resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<PasswordResetViewModel>(
            builder: (context, viewModel, child) {
              final state = viewModel.state;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        '비밀번호 재설정',
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '입력하신 이메일로 비밀번호를 재설정 할 수 있는 링크를 전송합니다. 이메일을 작성해주세요.',
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // 이메일 입력 필드
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputField(
                        label: '이메일',
                        hintText: '이메일을 입력해주세요.',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 40),

                      // 성공 메시지
                      if (state.isSuccess)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: const Text(
                            '비밀번호 재설정 이메일이 전송되었습니다.\n이메일을 확인해주세요.',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // 이메일 발송 버튼
                      ClickButton(
                        buttonText: state.isLoading ? '전송 중...' : '이메일 발송',
                        onPressed: state.isLoading
                            ? null
                            : () {
                          viewModel.resetPassword(
                            onSuccess: () {
                              // 성공 메시지는 state.isSuccess를 통해 표시됨
                            },
                            onError: _showError,
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      // 로그인 화면으로 돌아가기
                      GestureDetector(
                        onTap: () {
                          viewModel.resetState();
                          context.go(Routes.signIn);
                        },
                        child: const Center(
                          child: Text(
                            '로그인 화면으로 돌아가기',
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              color: Color(0xFF2E8B57),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
    super.dispose();
  }
}