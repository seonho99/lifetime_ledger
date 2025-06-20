import 'package:flutter/material.dart';

class ExpenseTrackerScreen extends StatelessWidget {
  const ExpenseTrackerScreen({Key? key}) : super(key: key);

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
                  Container(
                    width: 46,
                    height: 2,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: Text(
                      '2025 년 5월',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 2,
                    color: Colors.black,
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
                '이번달 총 지출: 1,000,000 원',
                style: TextStyle(
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
          style: TextStyle(
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
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          date,
          style: TextStyle(
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
      decoration: BoxDecoration(
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
            color: Color(0xFFD9D9D9),
            margin: const EdgeInsets.only(right: 20),
          ),

          // 상점명
          Expanded(
            flex: 2,
            child: Text(
              storeName,
              style: TextStyle(
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
              style: TextStyle(
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
              style: TextStyle(
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

// 메인 앱
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가계부 앱',
      home: ExpenseTrackerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
