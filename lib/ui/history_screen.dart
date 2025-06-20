import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _currentDate = DateTime.now();

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

  // 월 표시 포맷 (예: "2025년 5월")
  String get _formattedMonth {
    return DateFormat('yyyy년 M월', 'ko_KR').format(_currentDate);
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
                  _buildNavTab('내역', true),
                  _buildNavTab('소비', false),
                  _buildNavTab('달력', false),
                  _buildNavTab('설정', false),
                  _buildNavTab('통계', false),
                ],
              ),
            ),

            // 선택된 탭 하단 라인
            Container(
              margin: const EdgeInsets.only(left: 37, top: 8, bottom: 16),
              width: 41,
              height: 1,
              color: Colors.black,
              alignment: Alignment.centerLeft,
            ),

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
              child: ListView(
                children: [
                  _buildDateSection('19일 목요일'),
                  _buildTransactionItem('xx마트', '오후 12:30', '100,000 원'),
                  _buildTransactionItem('xxxxxxx카페', '오전 9:30', '5,000 원'),

                  _buildDateSection('18일 수요일'),
                  _buildTransactionItem('xx마트', '오후 10:30', '100,000 원'),
                  _buildTransactionItem('xx카페', '오후 2:30', '5,000 원'),
                  _buildTransactionItem('xx식당', '오전 8:30', '10,000 원'),

                  _buildDateSection('17일 화요일'),
                  _buildTransactionItem('xx마트', '오후 10:30', '100,000 원'),
                  _buildTransactionItem('xx카페', '오후 2:30', '5,000 원'),
                  _buildTransactionItem('xx식당', '오전 8:30', '10,000 원'),

                  _buildDateSection('16일 월요일'),
                  _buildTransactionItem('xx마트', '오후 10:30', '100,000 원'),
                  _buildTransactionItem('xx카페', '오후 2:30', '5,000 원'),
                  _buildTransactionItem('xx식당', '오전 8:30', '10,000 원'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTab(String title, bool isSelected) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
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