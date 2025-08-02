import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../core/route/routes.dart';
import '../../domain/model/history.dart';
import 'history_viewmodel.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
      final now = DateTime.now();
      viewModel.loadHistoriesByMonth(now.year, now.month);
      // ✅ 전체 자산 계산 추가
      viewModel.calculateTotalAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildHeader(viewModel),
              
              // Loading Indicator
              if (viewModel.isLoading)
                const LinearProgressIndicator(
                  backgroundColor: Color(0xFFEDEDED),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF141414)),
                ),
              
              // Error Message
              if (viewModel.hasError)
                _buildErrorMessage(viewModel),

              // Scrollable Content
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Account Info Section
                    SliverToBoxAdapter(
                      child: _buildAccountInfoSection(viewModel),
                    ),

                    // Month Selector
                    SliverToBoxAdapter(
                      child: _buildMonthSelector(viewModel),
                    ),

                    // Stats Cards Section  
                    SliverToBoxAdapter(
                      child: _buildStatsCards(viewModel),
                    ),

                    // Filter Tabs
                    SliverToBoxAdapter(
                      child: _buildFilterTabs(viewModel),
                    ),
                    
                    // Recent Transactions Header
                    SliverToBoxAdapter(
                      child: _buildRecentTransactionsHeader(viewModel),
                    ),

                    // Transactions List
                    _buildTransactionsSliver(viewModel),
                  ],
                ),
              ),

              // Action Buttons
              _buildActionButtons(),

            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(HistoryViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            child: const Icon(
              Icons.account_balance_wallet,
              size: 24,
              color: Color(0xFF141414),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(right: 48),
              child: const Text(
                'Lifetime Ledger',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF141414),
                  fontFamily: 'Noto Sans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection(HistoryViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Info
                Column(
                  children: [
                    const Text(
                      '오늘도 알뜰하게!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF737373),
                        fontFamily: 'Noto Sans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.formattedTotalAssets,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: viewModel.totalAssets >= 0 
                            ? const Color(0xFF141414) 
                            : Colors.red,
                        fontFamily: 'Noto Sans',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorMessage(HistoryViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              viewModel.errorMessage ?? '오류가 발생했습니다',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          TextButton(
            onPressed: viewModel.retryLastAction,
            child: const Text('재시도'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthSelector(HistoryViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: viewModel.goToPreviousMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            viewModel.selectedMonthString,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF141414),
            ),
          ),
          IconButton(
            onPressed: viewModel.goToNextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCards(HistoryViewModel viewModel) {
    final numberFormat = NumberFormat('#,###', 'ko_KR');
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDBDBDB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '총 지출',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF141414),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${numberFormat.format(viewModel.totalExpense)}원',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDBDBDB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '총 수입',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF141414),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${numberFormat.format(viewModel.totalIncome)}원',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterTabs(HistoryViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterTab(
            '전체',
            null,
            viewModel.state.filterType == null,
            () => viewModel.setFilter(null),
          ),
          const SizedBox(width: 8),
          _buildFilterTab(
            '수입',
            HistoryType.income,
            viewModel.state.filterType == HistoryType.income,
            () => viewModel.setFilter(HistoryType.income),
          ),
          const SizedBox(width: 8),
          _buildFilterTab(
            '지출',
            HistoryType.expense,
            viewModel.state.filterType == HistoryType.expense,
            () => viewModel.setFilter(HistoryType.expense),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterTab(
    String title,
    HistoryType? type,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF141414) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF141414) : const Color(0xFFDBDBDB),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF737373),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecentTransactionsHeader(HistoryViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '최근 거래내역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF141414),
              fontFamily: 'Noto Sans',
            ),
          ),
          Text(
            '${viewModel.histories.length}건',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF737373),
              fontFamily: 'Noto Sans',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionsList(HistoryViewModel viewModel) {
    if (viewModel.histories.isEmpty && !viewModel.isLoading) {
      return _buildEmptyTransactions();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.histories.length,
      itemBuilder: (context, index) {
        final history = viewModel.histories[index];
        return _buildHistoryItem(history);
      },
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48, // 크기 줄임
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12), // 간격 줄임
          Text(
            '아직 거래 내역이 없습니다',
            style: TextStyle(
              fontSize: 14, // 폰트 크기 줄임
              color: Colors.grey[600],
              fontFamily: 'Noto Sans',
            ),
          ),
          const SizedBox(height: 4), // 간격 줄임
          Text(
            '수입이나 지출을 추가해보세요!',
            style: TextStyle(
              fontSize: 12, // 폰트 크기 줄임
              color: Colors.grey[500],
              fontFamily: 'Noto Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSliver(HistoryViewModel viewModel) {
    if (viewModel.histories.isEmpty && !viewModel.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyTransactions(),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final history = viewModel.histories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildHistoryItem(history),
          );
        },
        childCount: viewModel.histories.length,
      ),
    );
  }
  
  Widget _buildHistoryItem(History history) {
    final numberFormat = NumberFormat('#,###', 'ko_KR');
    final isIncome = history.type == HistoryType.income;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isIncome ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  _getCategoryIcon(history.categoryId, isIncome),
                  color: isIncome ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF141414),
                      fontFamily: 'Noto Sans',
                    ),
                  ),
                  Text(
                    history.categoryId ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF737373),
                      fontFamily: 'Noto Sans',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${isIncome ? '+' : '-'}₩${numberFormat.format(history.amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isIncome ? Colors.green : Colors.red,
              fontFamily: 'Noto Sans',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.go(Routes.addIncome);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                '수입 추가',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.go(Routes.addExpense);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.remove, size: 18),
              label: const Text(
                '지출 추가',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리에 따른 아이콘 반환
  IconData _getCategoryIcon(String categoryId, bool isIncome) {
    if (isIncome) {
      // 수입 카테고리별 아이콘
      switch (categoryId.toLowerCase()) {
        case '급여':
        case 'salary':
          return Icons.work_outline;
        case '부업':
        case '사업':
        case 'business':
          return Icons.business_center_outlined;
        case '투자':
        case 'investment':
          return Icons.trending_up;
        case '용돈':
        case '선물':
        case 'gift':
          return Icons.card_giftcard_outlined;
        case '보너스':
        case 'bonus':
          return Icons.emoji_events_outlined;
        case '로열티':
        case 'royalty':
          return Icons.copyright_outlined;
        case '기타':
        case 'other':
          return Icons.more_horiz;
        default:
          return Icons.add_circle;
      }
    } else {
      // 지출 카테고리별 아이콘
      switch (categoryId.toLowerCase()) {
        case '식비':
        case '음식':
        case 'food':
          return Icons.restaurant_outlined;
        case '교통':
        case 'transport':
          return Icons.directions_car_outlined;
        case '쇼핑':
        case 'shopping':
          return Icons.shopping_bag_outlined;
        case '주거':
        case '집':
        case 'housing':
          return Icons.home_outlined;
        case '의료':
        case '건강':
        case 'medical':
          return Icons.medical_services_outlined;
        case '교육':
        case 'education':
          return Icons.school_outlined;
        case '문화':
        case '여가':
        case 'entertainment':
          return Icons.movie_outlined;
        case '통신':
        case 'communication':
          return Icons.phone_outlined;
        case '기타':
        case 'other':
          return Icons.more_horiz;
        default:
          return Icons.remove_circle;
      }
    }
  }
}