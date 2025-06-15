# 화면 설계 가이드

## 1. 화면 구조

### 1. 기본 구조
```dart
class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('거래 내역'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: const TransactionList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 2. 상태 관리 통합
```dart
class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionBloc(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
      ),
      child: const TransactionView(),
    );
  }
}

class TransactionView extends StatelessWidget {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('거래 내역'),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (transactions) => TransactionList(transactions: transactions),
            error: (message) => Center(child: Text(message)),
          );
        },
      ),
    );
  }
}
```

## 2. 화면 구성 요소

### 1. AppBar
```dart
AppBar(
  title: const Text('거래 내역'),
  leading: IconButton(
    icon: const Icon(Icons.menu),
    onPressed: () {},
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {},
    ),
    IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(48),
    child: TabBar(
      tabs: [
        Tab(text: '수입'),
        Tab(text: '지출'),
      ],
    ),
  ),
)
```

### 2. Body
```dart
body: SafeArea(
  child: Column(
    children: [
      // 상단 요약 정보
      const TransactionSummary(),
      
      // 필터 및 검색
      const TransactionFilter(),
      
      // 거래 목록
      Expanded(
        child: TransactionList(),
      ),
    ],
  ),
)
```

### 3. Bottom Navigation
```dart
bottomNavigationBar: NavigationBar(
  destinations: const [
    NavigationDestination(
      icon: Icon(Icons.home),
      label: '홈',
    ),
    NavigationDestination(
      icon: Icon(Icons.list),
      label: '거래',
    ),
    NavigationDestination(
      icon: Icon(Icons.pie_chart),
      label: '통계',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings),
      label: '설정',
    ),
  ],
  onDestinationSelected: (index) {
    // 네비게이션 처리
  },
)
```

## 3. 화면 전환

### 1. 기본 전환
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TransactionDetailScreen(),
  ),
);
```

### 2. GoRouter 사용
```dart
context.push('/transactions/detail');
```

### 3. 애니메이션 전환
```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const TransactionDetailScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
);
```

## 4. 화면 상태 관리

### 1. 로딩 상태
```dart
BlocBuilder<TransactionBloc, TransactionState>(
  builder: (context, state) {
    if (state is TransactionLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return const TransactionList();
  },
)
```

### 2. 에러 상태
```dart
BlocBuilder<TransactionBloc, TransactionState>(
  builder: (context, state) {
    if (state is TransactionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            ElevatedButton(
              onPressed: () {
                context.read<TransactionBloc>().add(LoadTransactions());
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    return const TransactionList();
  },
)
```

## 5. Best Practices

### 1. 화면 구성
- 명확한 계층 구조
- 일관된 레이아웃
- 재사용 가능한 컴포넌트
- 반응형 디자인

### 2. 상태 관리
- BLoC 패턴 사용
- 상태 분리
- 에러 처리
- 로딩 상태 처리

### 3. 성능
- 불필요한 리빌드 방지
- 이미지 최적화
- 레이아웃 최적화
- 메모리 관리

### 4. 접근성
- 시맨틱 레이블
- 키보드 네비게이션
- 스크린 리더 지원
- 색상 대비

## 6. 체크리스트

### 1. 기본 구성
- [ ] AppBar 구성
- [ ] Body 구성
- [ ] Bottom Navigation
- [ ] Floating Action Button

### 2. 상태 관리
- [ ] BLoC 통합
- [ ] 상태 처리
- [ ] 에러 처리
- [ ] 로딩 처리

### 3. 네비게이션
- [ ] 화면 전환
- [ ] 애니메이션
- [ ] 딥링크
- [ ] 뒤로가기

### 4. 성능
- [ ] 리빌드 최적화
- [ ] 이미지 최적화
- [ ] 레이아웃 최적화
- [ ] 메모리 관리
