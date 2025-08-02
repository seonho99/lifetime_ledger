import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/route/routes.dart';
import '../../domain/model/history.dart';
import '../history/history_viewmodel.dart';

/// 지출 추가 화면
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  
  String _selectedCategory = '식비';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _categories = [
    '식비',
    '교통',
    '쇼핑',
    '주거',
    '의료',
    '교육',
    '문화',
    '통신',
    '기타',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '지출 추가',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Noto Sans',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(Routes.history),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 금액 입력
                _buildAmountSection(),
                
                const SizedBox(height: 30),
                
                // 제목 입력
                _buildTitleSection(),
                
                const SizedBox(height: 24),
                
                // 카테고리 선택
                _buildCategorySection(),
                
                const SizedBox(height: 24),
                
                // 날짜 선택
                _buildDateSection(),
                
                const SizedBox(height: 24),
                
                // 메모 입력
                _buildMemoSection(),
                
                const SizedBox(height: 40),
                
                // 저장 버튼
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '금액',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF141414),
            fontFamily: 'Noto Sans',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsSeparatorInputFormatter(),
            ],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.red,
              fontFamily: 'Noto Sans',
            ),
            decoration: const InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              prefixText: '₩ ',
              prefixStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '금액을 입력해주세요';
              }
              final amount = int.tryParse(value.replaceAll(',', ''));
              if (amount == null || amount <= 0) {
                return '올바른 금액을 입력해주세요';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '제목',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF141414),
            fontFamily: 'Noto Sans',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: _titleController,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Noto Sans',
            ),
            decoration: const InputDecoration(
              hintText: '지출 제목을 입력해주세요',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: 'Noto Sans',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '제목을 입력해주세요';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF141414),
            fontFamily: 'Noto Sans',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected ? Colors.red.shade600 : Colors.grey.shade200,
                  border: Border.all(
                    color: isSelected ? Colors.red.shade600 : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontFamily: 'Noto Sans',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '날짜',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF141414),
            fontFamily: 'Noto Sans',
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Noto Sans',
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '메모 (선택사항)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF141414),
            fontFamily: 'Noto Sans',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: _memoController,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Noto Sans',
            ),
            decoration: const InputDecoration(
              hintText: '메모를 입력해주세요',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: 'Noto Sans',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '지출 추가',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Noto Sans',
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        locale: const Locale('ko', 'KR'),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.red.shade600,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
      }
    } catch (e) {
      print('달력 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('달력을 열 수 없습니다: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  Future<void> _saveExpense() async {
    print('🚀 _saveExpense 메서드 시작');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ 폼 검증 실패');
      return;
    }

    print('✅ 폼 검증 성공');
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('💸 지출 추가 시작');
      print('제목: ${_titleController.text}');
      print('금액: ${_amountController.text}');
      print('카테고리: $_selectedCategory');
      print('날짜: $_selectedDate');
      print('메모: ${_memoController.text}');

      // 실제 지출 추가 로직
      print('⏳ 지출 데이터 생성 중...');
      
      // 금액에서 콤마 제거하고 숫자로 변환
      final amountText = _amountController.text.replaceAll(',', '');
      final amount = double.tryParse(amountText) ?? 0;
      
      // History 객체 생성
      final history = History(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID
        title: _titleController.text.trim(),
        amount: amount,
        type: HistoryType.expense,
        categoryId: _selectedCategory,
        date: _selectedDate,
        description: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      print('📝 생성된 History: ${history.toString()}');
      
      // HistoryViewModel을 통해 지출 추가 (백그라운드에서 실행)
      final historyViewModel = context.read<HistoryViewModel>();
      print('🔗 HistoryViewModel 연결됨');
      
      // 백그라운드에서 저장하고 바로 화면 이동
      historyViewModel.addHistory(history).catchError((error) {
        print('❌ 백그라운드 저장 실패: $error');
      });
      print('📤 백그라운드 저장 시작');

      print('✅ 지출 추가 완료');

      if (mounted) {
        print('📱 mounted 상태 확인됨');
        
        // 성공 메시지 표시
        print('📢 SnackBar 표시 중...');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '지출이 성공적으로 추가되었습니다!',
              style: TextStyle(fontFamily: 'Noto Sans'),
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(milliseconds: 1000),
          ),
        );

        // 바로 화면 이동
        print('🔙 내역 화면으로 즉시 이동...');
        context.go(Routes.history);
        print('✅ context.go(Routes.history) 실행 완료');
      } else {
        print('❌ mounted가 false라서 SnackBar/화면이동 실패');
      }
    } catch (e) {
      print('❌ 지출 추가 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '지출 추가 중 오류가 발생했습니다: $e',
              style: const TextStyle(fontFamily: 'Noto Sans'),
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// 천 단위 콤마 추가를 위한 InputFormatter
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 숫자만 추출
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // 천 단위 콤마 추가
    final int value = int.parse(digitsOnly);
    final String formatted = _addCommas(value.toString());

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addCommas(String value) {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}