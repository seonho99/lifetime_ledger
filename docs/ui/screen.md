# 🖥️ Screen 설계 가이드

---

## ✅ 목적

Screen은 **ChangeNotifierProvider 설정**과 **UI 렌더링**을 담당하는 계층이다.  
ViewModel을 Provider로 주입하고, Consumer를 통해 상태를 구독하여  
화면을 렌더링하는 역할을 수행한다.

---

## ✅ 설계 원칙

- Screen은 **ChangeNotifierProvider 설정**과 **View 분리**로 구성한다.
- View는 항상 **StatelessWidget**으로 작성한다.
- **Consumer/Selector**를 통해 ViewModel 상태를 구독한다.
- **context.read<ViewModel>()**로 ViewModel 메서드를 호출한다.
- 화면은 작은 빌드 함수로 세분화하여 유지보수성과 가독성을 높인다.
- 모든 상태 분기는 ViewModel의 상태 기반으로 처리한다.

---

## ✅ 파일 구조 및 위치

- 경로: `lib/features/{기능}/presentation/screens/`
- 파일명: `{기능명}_screen.dart`
- 클래스명: `{기능명}Screen`, `{기능명}View`

예시:  
`TransactionScreen`, `TransactionView`

---

## ✅ Screen 기본 구성 예시

### Screen 클래스 (ChangeNotifierProvider 설정)

```dart
class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
        addTransactionUseCase: context.read<AddTransactionUseCase>(),
        deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
      )..loadTransactions(), // 초기 데이터 로드
      child: const TransactionView(),
    );
  }
}
```

### View 클래스 (순수 UI)

```dart
class TransactionView extends StatelessWidget {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('거래 내역'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.read<TransactionViewModel>().navigateToAdd(context),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        // 에러 상태 처리
        if (viewModel.hasError) {
          return _buildErrorState(viewModel);
        }

        // 로딩 상태 처리
        if (viewModel.isLoading) {
          return _buildLoadingState();
        }

        // 데이터 상태 처리
        return _buildTransactionList(viewModel);
      },
    );
  }

  Widget _buildErrorState(TransactionViewModel viewModel) {
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

  Widget _buildTransactionList(TransactionViewModel viewModel) {
    if (viewModel.transactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final transaction = viewModel.transactions[index];
        return TransactionCard(
          title: transaction.title,
          amount: transaction.amount,
          type: transaction.type,
          category: transaction.categoryName,
          date: transaction.date,
          onTap: () => viewModel.navigateToDetail(context, transaction.id),
          onDelete: () => viewModel.deleteTransaction(transaction.id),
        );
      },
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
            '거래 내역이 없습니다',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '새로운 거래를 추가해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        return FloatingActionButton(
          onPressed: () => viewModel.navigateToAdd(context),
          child: const Icon(Icons.add),
        );
      },
    );
  }
}
```

---

## ✅ 상태 기반 렌더링

ViewModel의 상태를 기반으로 UI를 분기 처리한다.

### Consumer 패턴

```dart
Consumer<TransactionViewModel>(
  builder: (context, viewModel, child) {
    // 상태별 UI 분기
    if (viewModel.hasError) {
      return ErrorWidget(message: viewModel.errorMessage!);
    }
    
    if (viewModel.isLoading) {
      return LoadingWidget();
    }
    
    return SuccessWidget(data: viewModel.transactions);
  },
)
```

### Selector 패턴 (성능 최적화)

```dart
// 특정 상태만 구독
Selector<TransactionViewModel, bool>(
  selector: (context, viewModel) => viewModel.isLoading,
  builder: (context, isLoading, child) {
    return isLoading 
        ? const CircularProgressIndicator()
        : const SizedBox.shrink();
  },
)

// 리스트 길이만 구독
Selector<TransactionViewModel, int>(
  selector: (context, viewModel) => viewModel.transactions.length,
  builder: (context, count, child) {
    return Text('총 $count개의 거래');
  },
)
```

---

## ✅ _buildXXX 함수 분리 원칙

Screen은 복잡해질 수 있는 화면 구조를 작은 빌드 함수로 세분화하여 유지보수성을 높인다.

### 세분화 기준
- UI 구조가 2~3단계 이상 중첩될 때
- 반복적인 리스트나 카드 뷰를 그릴 때
- 조건 분기가 필요한 상태를 표시할 때
- Consumer가 필요한 위젯 그룹

### 작성 규칙
- `_buildHeader()`, `_buildList()`, `_buildBody()`처럼 목적에 맞게 명확히 함수명을 작성한다.
- 하나의 _buildXXX 함수는 하나의 역할만 수행한다.
- _buildXXX 함수에서는 Consumer로 ViewModel 상태에 접근한다.
- ViewModel 메서드 호출은 `context.read<ViewModel>()`을 사용한다.

### 예시

```dart
Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Text('총 잔액: ₩${viewModel.totalBalance}'),
            Text('이번 달 지출: ₩${viewModel.monthlyExpense}'),
          ],
        );
      },
    ),
  );
}

Widget _buildFilterSection() {
  return Selector<TransactionViewModel, String?>(
    selector: (context, viewModel) => viewModel.selectedCategory,
    builder: (context, selectedCategory, child) {
      return FilterChips(
        selectedCategory: selectedCategory,
        onCategorySelected: (category) {
          context.read<TransactionViewModel>().filterByCategory(category);
        },
      );
    },
  );
}
```

---

## ✅ 파라미터가 있는 Screen

### URL 파라미터 처리

```dart
class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;
  
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionDetailViewModel(
        transactionId: transactionId,
        getTransactionUseCase: context.read<GetTransactionUseCase>(),
        updateTransactionUseCase: context.read<UpdateTransactionUseCase>(),
        deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
      )..loadTransaction(),
      child: const TransactionDetailView(),
    );
  }
}
```

---

## ✅ 책임 분리 요약

| 계층 | 책임 |
|:---|:---|
| **Screen** | ChangeNotifierProvider 설정, ViewModel 의존성 주입 |
| **View** | Consumer로 상태 구독, UI 렌더링, ViewModel 메서드 호출 |
| **ViewModel** | 상태 관리, UseCase 호출, 비즈니스 로직 실행, 네비게이션 |

---

## ✅ 테스트 전략

### Widget 테스트

```dart
group('TransactionScreen 위젯 테스트', () {
  testWidgets('로딩 상태에서 CircularProgressIndicator 표시', (tester) async {
    // Given
    final mockViewModel = MockTransactionViewModel();
    when(() => mockViewModel.isLoading).thenReturn(true);
    when(() => mockViewModel.hasError).thenReturn(false);

    // When
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TransactionViewModel>.value(
          value: mockViewModel,
          child: const TransactionView(),
        ),
      ),
    );

    // Then
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('에러 상태에서 에러 메시지 표시', (tester) async {
    // Given
    final mockViewModel = MockTransactionViewModel();
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.hasError).thenReturn(true);
    when(() => mockViewModel.errorMessage).thenReturn('네트워크 오류');

    // When
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TransactionViewModel>.value(
          value: mockViewModel,
          child: const TransactionView(),
        ),
      ),
    );

    // Then
    expect(find.text('네트워크 오류'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('거래 목록이 있을 때 리스트 렌더링', (tester) async {
    // Given
    final transactions = [
      Transaction.create(
        title: '커피',
        amount: 4500,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime.now(),
      ),
    ];
    
    final mockViewModel = MockTransactionViewModel();
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.hasError).thenReturn(false);
    when(() => mockViewModel.transactions).thenReturn(transactions);

    // When
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TransactionViewModel>.value(
          value: mockViewModel,
          child: const TransactionView(),
        ),
      ),
    );

    // Then
    expect(find.text('커피'), findsOneWidget);
    expect(find.text('₩4500'), findsOneWidget);
  });
});
```

---

## 📌 최종 요약

- Screen은 ChangeNotifierProvider 설정을 담당한다.
- View는 StatelessWidget으로 작성하고 Consumer로 상태를 구독한다.
- ViewModel 메서드 호출은 `context.read<ViewModel>()`을 사용한다.
- 화면 요소는 _buildXXX() 함수로 작은 단위로 나눈다.
- Selector를 활용하여 성능을 최적화한다.
- 상태별 UI 분기는 ViewModel의 상태 속성을 기반으로 한다.

---
