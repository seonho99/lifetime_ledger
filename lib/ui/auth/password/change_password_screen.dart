import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'change_password_viewmodel.dart';

/// ChangePassword Screen - Global Provider 사용
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // main.dart에서 전역 Provider로 설정된 ViewModel 사용
    return const ChangePasswordView();
  }
}

/// ChangePassword View (StatefulWidget UI)
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // ViewModel과 컨트롤러 동기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ChangePasswordViewModel>();

      _currentPasswordController.addListener(() {
        viewModel.onCurrentPasswordChanged(_currentPasswordController.text);
      });

      _newPasswordController.addListener(() {
        viewModel.onNewPasswordChanged(_newPasswordController.text);
      });

      _confirmPasswordController.addListener(() {
        viewModel.onConfirmNewPasswordChanged(_confirmPasswordController.text);
      });
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<ChangePasswordViewModel>(
            builder: (context, viewModel, child) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // 안내 텍스트
                            const Text(
                              '보안을 위해 새로운 비밀번호로 변경해주세요.',
                              style: TextStyle(
                                fontFamily: 'Noto Sans',
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // 현재 비밀번호 입력
                            _buildCurrentPasswordField(viewModel),

                            const SizedBox(height: 20),

                            // 새 비밀번호 입력
                            _buildNewPasswordField(viewModel),

                            const SizedBox(height: 20),

                            // 새 비밀번호 확인
                            _buildConfirmPasswordField(viewModel),

                            const SizedBox(height: 40),

                            // 에러 메시지 표시
                            if (viewModel.hasError) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // 성공 메시지 표시
                            if (viewModel.hasSuccess) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Text(
                                  viewModel.successMessage!,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // 변경 버튼
                    _buildChangePasswordButton(viewModel),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPasswordField(ChangePasswordViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '현재 비밀번호',
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
              color: viewModel.currentPasswordError != null
                  ? Colors.red
                  : const Color(0xFFCFCFCF),
              width: 1.3,
            ),
          ),
          child: TextFormField(
            controller: _currentPasswordController,
            obscureText: viewModel.obscureCurrentPassword,
            decoration: InputDecoration(
              hintText: '현재 비밀번호를 입력해주세요',
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
                  viewModel.obscureCurrentPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: viewModel.toggleCurrentPasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '현재 비밀번호를 입력해주세요';
              }
              return null;
            },
          ),
        ),
        if (viewModel.currentPasswordError != null) ...[
          const SizedBox(height: 5),
          Text(
            viewModel.currentPasswordError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNewPasswordField(ChangePasswordViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '새 비밀번호',
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
              color: viewModel.newPasswordError != null
                  ? Colors.red
                  : const Color(0xFFCFCFCF),
              width: 1.3,
            ),
          ),
          child: TextFormField(
            controller: _newPasswordController,
            obscureText: viewModel.obscureNewPassword,
            decoration: InputDecoration(
              hintText: '새 비밀번호를 입력해주세요 (6자 이상)',
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
                  viewModel.obscureNewPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: viewModel.toggleNewPasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '새 비밀번호를 입력해주세요';
              }
              if (value.length < 6) {
                return '비밀번호는 6자 이상이어야 합니다';
              }
              return null;
            },
          ),
        ),
        if (viewModel.newPasswordError != null) ...[
          const SizedBox(height: 5),
          Text(
            viewModel.newPasswordError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmPasswordField(ChangePasswordViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '새 비밀번호 확인',
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
              width: 1.3,
            ),
          ),
          child: TextFormField(
            controller: _confirmPasswordController,
            obscureText: viewModel.obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: '새 비밀번호를 다시 입력해주세요',
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
                  viewModel.obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: viewModel.toggleConfirmPasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '새 비밀번호 확인을 입력해주세요';
              }
              if (value != _newPasswordController.text) {
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

  Widget _buildChangePasswordButton(ChangePasswordViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () => _handleChangePassword(viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: viewModel.isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          '비밀번호 변경',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _handleChangePassword(ChangePasswordViewModel viewModel) async {
    // 폼 유효성 검증
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ViewModel의 비밀번호 변경 호출
    await viewModel.changePassword(
      onSuccess: () {
        // 성공 시 처리
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호가 성공적으로 변경되었습니다'),
            backgroundColor: Colors.green,
          ),
        );

        // 잠시 후 이전 화면으로 돌아가기
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop();
          }
        });
      },
      onError: (message) {
        // 에러 시 처리 (ViewModel에서 이미 상태 업데이트됨)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}