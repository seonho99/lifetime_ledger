import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/datasource/history_datasource_impl.dart';
import '../../data/repository_impl/history_repository_impl.dart';
import '../../domain/repository/history_repository.dart';
import '../../domain/usecase/add_history_usecase.dart';
import '../../domain/usecase/delete_history_usecase.dart';
import '../../domain/usecase/get_histories_by_month_usecase.dart';
import '../../domain/usecase/get_histories_usecase.dart';
import '../../domain/usecase/update_history_usecase.dart';
import 'history_viewmodel.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // DataSource
        Provider(
          create: (context) => HistoryFirebaseDataSourceImpl(
            firestore: FirebaseFirestore.instance,
          ),
        ),

        // Repository
        Provider<HistoryRepository>(
          create: (context) => HistoryRepositoryImpl(
            dataSource: context.read<HistoryFirebaseDataSourceImpl>(),
          ),
        ),

        // UseCases
        Provider(
          create: (context) => GetHistoriesUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => AddHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => UpdateHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => DeleteHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => GetHistoriesByMonthUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),

        // ViewModel
        ChangeNotifierProvider(
          create: (context) => HistoryViewModel(
            getHistoriesUseCase: context.read<GetHistoriesUseCase>(),
            addHistoryUseCase: context.read<AddHistoryUseCase>(),
            updateHistoryUseCase: context.read<UpdateHistoryUseCase>(),
            deleteHistoryUseCase: context.read<DeleteHistoryUseCase>(),
            getHistoriesByMonthUseCase: context.read<GetHistoriesByMonthUseCase>(),
          )..loadHistoriesByMonth(DateTime.now().year, DateTime.now().month),
        ),
      ],
      child: const HistoryView(),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildNavTabs(),
            const SizedBox(height: 16),
            _buildMonthlyTotal(),
            Expanded(
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader() {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // 이전 달 버튼
              GestureDetector(
                onTap: () => viewModel.goToPreviousMonth(),
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
                  viewModel.selectedMonthString,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),

              // 다음 달 버튼
              GestureDetector(
                onTap: () => viewModel.goToNextMonth(),
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
        );
      },
    );
  }

  Widget _buildNavTabs() {
    final tabNames = ['내역', '소비', '달력', '설정', '통계'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < tabNames.length; i++)
            _buildNavTab(tabNames[i], i == 0), // 현재는 '내역' 탭만 활성화
        ],
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
    );
  }

  Widget _buildMonthlyTotal() {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Text(
            '${viewModel.selectedMonthString} 총 지출: ₩${viewModel.totalExpense.toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        // 에러 상태 처리
        if (viewModel.hasError) {
          return _buildErrorState(viewModel);
        }

        // 로딩 상태 처리
        if (viewModel.isLoading) {
          return _buildLoadingState();
        }

        // 빈 상태 처리
        if (viewModel.histories.isEmpty) {
          return _buildEmptyState();
        }

        // 내역 리스트
        return _buildHistoryItems(viewModel.histories);
      },
    );
  }

  Widget _buildErrorState(HistoryViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage ?? '오류가 발생했습니다',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.retryLastAction(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            '내역이 없습니다',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '새로운 내역을 추가해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItems(histories) {
    // 날짜별로 그룹화
    final groupedHistories = <String, List>{};
    for (final history in histories) {
      final dateKey = _formatDateKey(history.date);
      if (groupedHistories[dateKey] == null) {
        groupedHistories[dateKey] = [];
      }
      groupedHistories[dateKey]!.add(history);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          for (final dateKey in groupedHistories.keys) ...[
            _buildDateSection(dateKey),
            for (final history in groupedHistories[dateKey]!)
              _buildHistoryItem(history),
          ],
          const SizedBox(height: 80), // FloatingActionButton 공간
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

  Widget _buildHistoryItem(history) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFCDCACA), width: 1),
        ),
      ),
      child: Row(
        children: [
          // 카테고리 아이콘
          Container(
            width: 17,
            height: 17,
            color: const Color(0xFFD9D9D9),
            margin: const EdgeInsets.only(right: 20),
          ),

          // 제목
          Expanded(
            flex: 2,
            child: Text(
              history.title,
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

          // 시간 (임시로 공백)
          const Expanded(
            flex: 2,
            child: Text(
              '',
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
              history.formattedAmount,
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

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: 내역 추가 화면으로 이동
        debugPrint('내역 추가 버튼 클릭');
      },
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add, size: 28),
    );
  }

  String _formatDateKey(DateTime date) {
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final day = date.day;
    final weekday = weekdays[date.weekday - 1];
    return '${day}일 $weekday';
  }
}