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

## 전역 Provider 설정 (main.dart)
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repository
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(),
        ),
        
        // UseCase
        Provider<GetTransactionsUseCase>(
          create: (context) => GetTransactionsUseCase(
            repository: context.read<TransactionRepository>(),
          ),
        ),
      ],
      child: MaterialApp(home: TransactionScreen()),
    );
  }
}
```

## 화면별 ViewModel Provider
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

### context.read() - 메서드 호출용
```dart
onPressed: () => context.read<TransactionViewModel>().loadTransactions(),
```

### Consumer - 상태 구독
```dart
Consumer<TransactionViewModel>(
  builder: (context, viewModel, child) {
    return viewModel.isLoading 
      ? CircularProgressIndicator()
      : TransactionList(transactions: viewModel.transactions);
  },
)
```

### Selector - 성능 최적화
```dart
Selector<TransactionViewModel, bool>(
  selector: (context, viewModel) => viewModel.isLoading,
  builder: (context, isLoading, child) {
    return isLoading ? CircularProgressIndicator() : SizedBox.shrink();
  },
)
```

## 핵심 패턴
1. **전역**: Repository, UseCase (main.dart)
2. **화면별**: ViewModel (ChangeNotifierProvider)
3. **접근**: context.read() vs Consumer
4. **최적화**: Selector 사용