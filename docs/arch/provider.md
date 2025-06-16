# Provider 패턴 가이드

## Provider 라이브러리 개요

Provider는 Flutter에서 상태 관리를 위한 공식 권장 라이브러리입니다.
InheritedWidget을 기반으로 하여 위젯 트리에서 데이터를 효율적으로 공유할 수 있게 해줍니다.

## 기본 개념

### 1. Provider의 역할
- **상태 공유**: 위젯 트리에서 데이터를 공유
- **의존성 주입**: 필요한 객체들을 자동으로 주입
- **생명주기 관리**: 객체의 생성과 해제를 자동 관리

### 2. 주요 Provider 타입

#### Provider (일반 객체용)
```dart
Provider<Repository>(
create: (context) => TransactionRepository(),
child: MyApp(),
)
```

#### ChangeNotifierProvider (상태 관리용)
```dart
ChangeNotifierProvider<TransactionViewModel>(
create: (context) => TransactionViewModel(),
child: TransactionScreen(),
)
```

## 기본 사용 패턴

### 1. 간단한 MultiProvider 설정
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repository 주입
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(),
        ),
        
        // UseCase 주입
        Provider<GetTransactionsUseCase>(
          create: (context) => GetTransactionsUseCase(
            repository: context.read<TransactionRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        home: TransactionScreen(),
      ),
    );
  }
}
```

### 2. 화면별 ViewModel Provider
```dart
class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
      ),
      child: TransactionView(),
    );
  }
}
```

## 데이터 접근 방법

### 1. context.read() - 메서드 호출용
```dart
// 이벤트 처리 시 사용
onPressed: () => context.read<TransactionViewModel>().loadTransactions(),

// 의존성 주입 시 사용
Provider<GetTransactionsUseCase>(
  create: (context) => GetTransactionsUseCase(
    repository: context.read<TransactionRepository>(),
  ),
)
```

### 2. context.watch() - 상태 구독용
```dart
// 위젯에서 상태 구독
Widget build(BuildContext context) {
  final isLoading = context.watch<TransactionViewModel>().isLoading;
  
  return isLoading 
    ? CircularProgressIndicator()
    : TransactionList();
}
```

### 3. Consumer - 상태 구독 (권장)
```dart
Consumer<TransactionViewModel>(
  builder: (context, viewModel, child) {
    return viewModel.isLoading 
      ? CircularProgressIndicator()
      : TransactionList(transactions: viewModel.transactions);
  },
)
```

### 4. Selector - 성능 최적화
```dart
// 특정 속성만 구독하여 불필요한 리빌드 방지
Selector<TransactionViewModel, bool>(
  selector: (context, viewModel) => viewModel.isLoading,
  builder: (context, isLoading, child) {
    return isLoading 
      ? CircularProgressIndicator() 
      : SizedBox.shrink();
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

## Provider 사용 패턴

### 1. 전역 vs 지역 Provider
```dart
// 전역: 앱 전체에서 사용하는 객체들 (main.dart)
MultiProvider(
  providers: [
    Provider<TransactionRepository>(...),  // 전역
    Provider<GetTransactionsUseCase>(...), // 전역
  ],
  child: MyApp(),
)

// 지역: 특정 화면에서만 사용하는 ViewModel (Screen)
ChangeNotifierProvider(
  create: (context) => TransactionViewModel(...), // 지역
  child: TransactionView(),
)
```

### 2. 의존성 주입 체인
```dart
MultiProvider(
  providers: [
    // 1단계: 기본 서비스
    Provider<ApiService>(
      create: (context) => ApiServiceImpl(),
    ),
    
    // 2단계: Repository (ApiService 의존)
    Provider<TransactionRepository>(
      create: (context) => TransactionRepositoryImpl(
        apiService: context.read<ApiService>(),
      ),
    ),
    
    // 3단계: UseCase (Repository 의존)
    Provider<GetTransactionsUseCase>(
      create: (context) => GetTransactionsUseCase(
        repository: context.read<TransactionRepository>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

## 성능 최적화

### 1. Consumer vs Selector 선택
```dart
// ❌ 전체 ViewModel 구독 (비효율적)
Consumer<TransactionViewModel>(
  builder: (context, viewModel, child) {
    return Text('로딩: ${viewModel.isLoading}'); // isLoading만 필요한데 전체 구독
  },
)

// ✅ 필요한 부분만 구독 (효율적)
Selector<TransactionViewModel, bool>(
  selector: (context, viewModel) => viewModel.isLoading,
  builder: (context, isLoading, child) {
    return Text('로딩: $isLoading');
  },
)
```

### 2. child 파라미터 활용
```dart
Consumer<TransactionViewModel>(
  builder: (context, viewModel, child) {
    return Column(
      children: [
        Text('거래 수: ${viewModel.transactions.length}'),
        child!, // 변경되지 않는 위젯은 child로 분리
      ],
    );
  },
  child: const ExpensiveWidget(), // 한 번만 생성되고 재사용
)
```

### 3. 적절한 Provider 범위 설정
```dart
// ❌ 너무 높은 범위 (불필요한 리빌드)
class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return ChangeNotifierProvider( // 너무 상위에 배치
      create: (context) => TransactionViewModel(),
      child: MaterialApp(
        home: HomeScreen(), // TransactionViewModel이 필요 없는 화면도 포함
      ),
    );
  }
}

// ✅ 적절한 범위 (필요한 곳에만)
class TransactionScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return ChangeNotifierProvider( // 필요한 화면에만 배치
      create: (context) => TransactionViewModel(),
      child: TransactionView(),
    );
  }
}
```

## 에러 처리 패턴

### 1. Provider에서 에러 처리
```dart
Consumer<TransactionViewModel>(
  builder: (context, viewModel, child) {
    // 에러 상태 확인
    if (viewModel.hasError) {
      return ErrorWidget(
        message: viewModel.errorMessage!,
        onRetry: () => viewModel.loadTransactions(),
      );
    }
    
    // 로딩 상태 확인
    if (viewModel.isLoading) {
      return LoadingWidget();
    }
    
    // 정상 상태
    return TransactionList(transactions: viewModel.transactions);
  },
)
```

### 2. 여러 Provider 조합
```dart
class TransactionSummaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionViewModel, CategoryViewModel>(
      builder: (context, transactionVM, categoryVM, child) {
        return Column(
          children: [
            Text('총 거래: ${transactionVM.transactions.length}'),
            Text('카테고리: ${categoryVM.categories.length}'),
          ],
        );
      },
    );
  }
}
```

## Best Practices

### 1. Provider 계층
- **전역**: Repository, UseCase, Service (main.dart)
- **화면**: ViewModel (Screen별 ChangeNotifierProvider)
- **접근**: read() vs watch() vs Consumer 적절히 선택

### 2. 의존성 관리
- **단방향 의존성**: 상위 → 하위로만 의존
- **인터페이스 활용**: 구현체가 아닌 인터페이스에 의존
- **생명주기 고려**: Provider가 객체 생명주기 자동 관리

### 3. 성능 고려사항
- **Selector 활용**: 필요한 상태만 구독
- **child 파라미터**: 불변 위젯 재사용
- **적절한 범위**: Provider를 필요한 곳에만 배치

## 체크리스트

### Provider 설정
- [ ] MultiProvider로 전역 의존성 설정
- [ ] ChangeNotifierProvider로 화면별 ViewModel 설정
- [ ] 의존성 주입 순서 확인
- [ ] Provider 범위 적절히 설정

### 데이터 접근
- [ ] read() vs watch() 구분해서 사용
- [ ] Consumer로 상태 구독
- [ ] Selector로 성능 최적화
- [ ] 에러 상태 적절히 처리

### 성능 최적화
- [ ] 불필요한 리빌드 방지
- [ ] child 파라미터 활용
- [ ] Provider 범위 최적화
- [ ] 메모리 누수 방지