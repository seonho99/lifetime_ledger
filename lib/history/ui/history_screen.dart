import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _currentDate = DateTime.now();
  int _selectedTabIndex = 0; // 현재 선택된 탭 (0: 내역)

  // 탭 목록
  final List<String> _tabNames = ['내역', '소비', '달력', '설정', '통계'];

  // 거래 내역 데이터 (날짜별로 그룹화)
  Map<String, List<Map<String, String>>> _transactions = {
    '19일 목요일': [
      {'storeName': 'xx마트', 'time': '오후 12:30', 'amount': '100,000 원'},
      {'storeName': 'xxxxxxx카페', 'time': '오전 9:30', 'amount': '5,000 원'},
    ],
    '18일 수요일': [
      {'storeName': 'xx마트', 'time': '오후 10:30', 'amount': '100,000 원'},
      {'storeName': 'xx카페', 'time': '오후 2:30', 'amount': '5,000 원'},
      {'storeName': 'xx식당', 'time': '오전 8:30', 'amount': '10,000 원'},
    ],
    '17일 화요일': [
      {'storeName': 'xx마트', 'time': '오후 10:30', 'amount': '100,000 원'},
      {'storeName': 'xx카페', 'time': '오후 2:30', 'amount': '5,000 원'},
      {'storeName': 'xx식당', 'time': '오전 8:30', 'amount': '10,000 원'},
    ],
    '16일 월요일': [
      {'storeName': 'xx마트', 'time': '오후 10:30', 'amount': '100,000 원'},
      {'storeName': 'xx카페', 'time': '오후 2:30', 'amount': '5,000 원'},
      {'storeName': 'xx식당', 'time': '오전 8:30', 'amount': '10,000 원'},
    ],
  };

  // 이전 달로 이동
  void _goToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  // 다음 달로 이동
  void _goToNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  // 탭 선택 처리
  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });

    // 각 탭에 따른 화면 이동 처리
    switch (index) {
      case 0: // 내역
      // 현재 화면이므로 아무것도 하지 않음
        break;
      case 1: // 소비
        _navigateToExpenseScreen();
        break;
      case 2: // 달력
        _navigateToCalendarScreen();
        break;
      case 3: // 설정
        _navigateToSettingsScreen();
        break;
      case 4: // 통계
        _navigateToStatisticsScreen();
        break;
    }
  }

  // 각 화면으로의 네비게이션 메서드들
  void _navigateToExpenseScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('소비 화면으로 이동 (준비 중)')),
    );
  }

  void _navigateToCalendarScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('달력 화면으로 이동 (준비 중)')),
    );
  }

  void _navigateToSettingsScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('설정 화면으로 이동 (준비 중)')),
    );
  }

  void _navigateToStatisticsScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('통계 화면으로 이동 (준비 중)')),
    );
  }

  // 새 거래 추가 다이얼로그 표시
  void _onAddTransaction() {
    _showAddTransactionDialog();
  }

  // 거래 추가 다이얼로그
  void _showAddTransactionDialog() {
    final TextEditingController storeController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    // 시간 선택을 위한 상태 변수
    String selectedPeriod = '오후'; // 기본값: 오후

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                '소비 내역',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 소비처 입력
                    TextField(
                      controller: storeController,
                      decoration: const InputDecoration(
                        labelText: '소비처',
                        hintText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 시간 입력 (오전/오후 선택 + 시간)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '시간',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 오전/오후 선택 버튼
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedPeriod = '오전';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: selectedPeriod == '오전'
                                        ? Colors.black
                                        : Colors.grey[200],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                    border: Border.all(
                                      color: selectedPeriod == '오전'
                                          ? Colors.black
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    '오전',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: selectedPeriod == '오전'
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedPeriod = '오후';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: selectedPeriod == '오후'
                                        ? Colors.black
                                        : Colors.grey[200],
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                    border: Border.all(
                                      color: selectedPeriod == '오후'
                                          ? Colors.black
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    '오후',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: selectedPeriod == '오후'
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 시간 입력 필드
                        TextField(
                          controller: timeController,
                          decoration: const InputDecoration(
                            hintText: '',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 금액 입력
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '금액',
                        hintText: '',
                        border: OutlineInputBorder(),
                        suffixText: '원',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 시간을 오전/오후 + 시간으로 결합
                    final fullTime = timeController.text.isNotEmpty
                        ? '$selectedPeriod ${timeController.text}'
                        : '';

                    _addTransaction(
                      storeController.text,
                      fullTime,
                      amountController.text,
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 거래 추가 처리
  void _addTransaction(String storeName, String time, String amount) {
    if (storeName.isEmpty || time.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    // 현재 날짜를 기준으로 요일 생성
    final now = DateTime.now();
    final dateKey = _formatDateKey(now);

    // 금액 포맷팅 (숫자만 입력받아서 "xxx 원" 형태로 변환)
    final formattedAmount = _formatAmount(amount);

    setState(() {
      if (_transactions[dateKey] == null) {
        _transactions[dateKey] = [];
      }

      // 새 거래를 리스트 맨 앞에 추가 (최신순)
      _transactions[dateKey]!.insert(0, {
        'storeName': storeName,
        'time': time,
        'amount': formattedAmount,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$storeName 거래가 추가되었습니다.')),
    );
  }

  // 날짜를 "dd일 요일" 형태로 포맷팅 (한국어 수동 처리)
  String _formatDateKey(DateTime date) {
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final day = date.day;
    final weekday = weekdays[date.weekday - 1];
    return '${day}일 $weekday';
  }

  // 금액 포맷팅
  String _formatAmount(String amount) {
    // 숫자만 추출
    final numericAmount = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericAmount.isEmpty) return '0 원';

    // 천 단위 콤마 추가
    final formatter = NumberFormat('#,###');
    final formattedNumber = formatter.format(int.parse(numericAmount));

    return '$formattedNumber 원';
  }

  // 월 표시 포맷 (예: "2025년 5월") - 수동 처리
  String get _formattedMonth {
    final year = _currentDate.year;
    final month = _currentDate.month;
    return '${year}년 ${month}월';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (화살표 + 제목)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // 왼쪽 화살표 (이전 달)
                  GestureDetector(
                    onTap: _goToPreviousMonth,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // 중앙 제목
                  Expanded(
                    child: Text(
                      _formattedMonth,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // 오른쪽 화살표 (다음 달)
                  GestureDetector(
                    onTap: _goToNextMonth,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 네비게이션 탭
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < _tabNames.length; i++)
                    _buildNavTab(_tabNames[i], i == _selectedTabIndex, () => _onTabSelected(i)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 이번달 총 지출
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${_formattedMonth} 총 지출: 1,000,000 원',
                style: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),

            // 거래 내역 리스트
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 동적으로 거래 내역 생성
                    for (String dateKey in _transactions.keys) ...[
                      _buildDateSection(dateKey),
                      for (Map<String, String> transaction in _transactions[dateKey]!)
                        _buildTransactionItem(
                          transaction['storeName']!,
                          transaction['time']!,
                          transaction['amount']!,
                        ),
                    ],

                    // 리스트 하단에 여백 추가 (FloatingActionButton 공간 확보)
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // 하단 + 버튼 (FloatingActionButton)
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTransaction,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavTab(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 34,
              height: 1,
              color: Colors.black,
            ),
        ],
      ),
    );
  }

  Widget _buildDateSection(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          date,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String storeName, String time, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFCDCACA), width: 1),
        ),
      ),
      child: Row(
        children: [
          // 카테고리 아이콘 (회색 사각형)
          Container(
            width: 17,
            height: 17,
            color: const Color(0xFFD9D9D9),
            margin: const EdgeInsets.only(right: 20),
          ),

          // 상점명
          Expanded(
            flex: 2,
            child: Text(
              storeName,
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

          // 시간
          Expanded(
            flex: 2,
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFCCCCCC),
              ),
            ),
          ),

          // 금액
          Expanded(
            flex: 2,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}