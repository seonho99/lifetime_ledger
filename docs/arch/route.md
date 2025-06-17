# 🛣️ 라우팅 (Route) 설계 가이드

---

## ✅ 목적

- **GoRouter**를 통해 앱의 전체 라우팅 경로를 설정
- 경로(path)와 Screen을 연결하는 역할만 담당
- 라우팅은 네비게이션만 처리하고, 비즈니스 로직은 포함하지 않음
- **Provider + MVVM** 패턴과 자연스럽게 연동

---

## 🧱 설계 원칙

- GoRouter는 main.dart에서 설정하거나 별도 라우터 클래스로 관리
- Screen은 ChangeNotifierProvider 설정과 UI를 담당
- ViewModel은 UseCase 호출과 상태 관리를 담당
- Route는 경로-Screen 매핑만 담당하며, 상태/인증 체크 등 비즈니스 로직을 처리하지 않음
- ViewModel에서 네비게이션 메서드를 제공하여 UI 이벤트 처리

---

## ✅ 파일 구조 및 위치

```
lib/
├── core/
│   └── router/
│       └── app_router.dart              # 메인 라우터 설정
├── features/
│   └── {기능}/
│       └── presentation/
│           └── screens/
│               ├── {기능}_screen.dart   # ChangeNotifierProvider + UI
│               └── {기능}_view.dart     # 순수 UI (선택적)
└── main.dart                            # GoRouter 설정
```

---

## ✅ 기본 라우터 설정

### main.dart에서 GoRouter 설정

```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // 홈
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    
    // 거래 관련
    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionScreen(),
    ),
    GoRoute(
      path: '/transactions/add',
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/transactions/:id',
      builder: (context, state) => TransactionDetailScreen(
        transactionId: state.pathParameters['id']!,
      ),
    ),
    
    // 카테고리 관련
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoryScreen(),
    ),
    
    // 통계
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 전역 Provider 설정
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(
            remoteDataSource: TransactionRemoteDataSourceImpl(),
            localDataSource: TransactionLocalDataSourceImpl(),
          ),
        ),
        Provider<GetTransactionsUseCase>(
          create: (context) => GetTransactionsUseCase(
            repository: context.read<TransactionRepository>(),
          ),
        ),
        // ... 다른 Provider들
      ],
      child: MaterialApp.router(
        title: 'Lifetime Ledger',
        routerConfig: router,
      ),
    );
  }
}
```

---

## 🏗️ Screen 구조 예시

### 1. 기본 Screen (ChangeNotifierProvider 설정)

```dart
class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
        addTransactionUseCase: context.read<AddTransactionUseCase>(),
      )..loadTransactions(),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/transactions/add'),
          ),
        ],
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.hasError) {
            return Center(child: Text(viewModel.errorMessage!));
          }
          
          return ListView.builder(
            itemCount: viewModel.transactions.length,
            itemBuilder: (context, index) {
              return TransactionCard(
                transaction: viewModel.transactions[index],
                onTap: () => viewModel.navigateToDetail(
                  context, 
                  viewModel.transactions[index].id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

### 2. Parameter가 있는 Screen

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

## 🔄 ViewModel에서 네비게이션 처리

### NavigationMixin 생성

```dart
mixin NavigationMixin {
  void navigateTo(BuildContext context, String path) {
    context.push(path);
  }

  void navigateAndReplace(BuildContext context, String path) {
    context.pushReplacement(path);
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  void navigateToRoot(BuildContext context, String path) {
    context.go(path);
  }

  Future<T?> navigateModal<T>(BuildContext context, String path) {
    return context.push<T>(path);
  }
}
```

### ViewModel에서 네비게이션 사용

```dart
class TransactionViewModel extends ChangeNotifier with NavigationMixin {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final AddTransactionUseCase _addTransactionUseCase;

  TransactionViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
    required AddTransactionUseCase addTransactionUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase,
       _addTransactionUseCase = addTransactionUseCase;

  // 상태 관리 로직...

  void navigateToDetail(BuildContext context, String transactionId) {
    navigateTo(context, '/transactions/$transactionId');
  }

  void navigateToAdd(BuildContext context) {
    navigateTo(context, '/transactions/add');
  }

  Future<void> addTransactionAndNavigateBack(
    BuildContext context, 
    Transaction transaction,
  ) async {
    final result = await _addTransactionUseCase(transaction);
    
    result.when(
      success: (_) {
        loadTransactions(); // 목록 새로고침
        navigateBack(context); // 이전 화면으로
      },
      error: (failure) {
        // 에러 처리
        _setError(failure.message);
      },
    );
  }
}
```

---

## 🔄 고급 라우팅 구조

### 1. ShellRoute 사용 (탭 구조)

```dart
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionScreen(),
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
      ],
    ),
  ],
);

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Consumer<NavigationViewModel>(
        builder: (context, navViewModel, child) {
          return BottomNavigationBar(
            currentIndex: navViewModel.currentIndex,
            onTap: (index) => navViewModel.navigateToIndex(context, index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: '거래',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart),
                label: '통계',
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### 2. 중첩 라우팅

```dart
GoRoute(
  path: '/transactions',
  builder: (context, state) => const TransactionScreen(),
  routes: [
    GoRoute(
      path: 'add',
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: ':id',
      builder: (context, state) => TransactionDetailScreen(
        transactionId: state.pathParameters['id']!,
      ),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => EditTransactionScreen(
            transactionId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
)
```

---

## 📋 라우팅 흐름

| 단계 | 역할 |
|:---|:---|
| GoRouter | 전체 경로 구성 및 초기 위치 설정 |
| Route | 경로 → Screen 연결 |
| Screen | ChangeNotifierProvider 설정 + UI 구성 |
| ViewModel | 상태 관리 + UseCase 호출 + 네비게이션 처리 |
| Consumer | 상태 구독 + UI 업데이트 |

---

## 🔄 네비게이션 메서드

### 기본 네비게이션

```dart
// 새 화면으로 이동 (스택에 추가)
context.push('/transactions/add');

// 현재 화면 교체
context.pushReplacement('/home');

// 전체 스택 교체
context.go('/login');

// 뒤로 가기
context.pop();

// 결과와 함께 뒤로 가기
context.pop(result);
```

### Named Route 네비게이션 (선택적)

```dart
GoRoute(
  name: 'transactionDetail',
  path: '/transactions/:id',
  builder: (context, state) => TransactionDetailScreen(
    transactionId: state.pathParameters['id']!,
  ),
)

// 사용
context.goNamed('transactionDetail', pathParameters: {'id': transactionId});
```

---

## 🔒 인증 및 라우트 가드

### Redirect를 이용한 인증 처리

```dart
final router = GoRouter(
  redirect: (context, state) {
    final authViewModel = context.read<AuthViewModel>();
    final isLoggedIn = authViewModel.isLoggedIn;
    final isLoginRoute = state.matchedLocation == '/login';
    
    // 로그인이 필요한 경우
    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }
    
    // 이미 로그인된 상태에서 로그인 페이지 접근
    if (isLoggedIn && isLoginRoute) {
      return '/';
    }
    
    return null; // 리다이렉션 없음
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // ... 다른 보호된 라우트들
  ],
);
```

---

## 📌 에러 처리

### 404 페이지

```dart
final router = GoRouter(
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [...],
);

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('페이지를 찾을 수 없음')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('요청하신 페이지를 찾을 수 없습니다.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ✅ 최종 요약

| 항목 | 요약 |
|:---|:---|
| Router 설정 | main.dart에서 GoRouter 설정 |
| Route | Path → Screen 연결만 담당 |
| Screen | ChangeNotifierProvider 설정 + UI 구성 |
| ViewModel | 상태 관리 + UseCase 호출 + 네비게이션 처리 |
| Navigation | ViewModel에서 NavigationMixin 사용 |
| 확장성 | ShellRoute, 중첩 라우팅 등 고급 구조 지원 |

---
