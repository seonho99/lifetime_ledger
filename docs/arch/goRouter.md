# 라우팅 가이드

## GoRouter 설정 (Provider 패턴)

### 1. 기본 라우터 구성
```dart
final router = GoRouter(
  initialLocation: '/',
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
      path: '/transactions/add',
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/transactions/:id',
      builder: (context, state) => TransactionDetailScreen(
        transactionId: state.pathParameters['id']!,
      ),
    ),
  ],
);
```

### 2. Provider와 라우팅 통합
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(),
        ),
        
        // UseCases
        Provider<GetTransactionsUseCase>(
          create: (context) => GetTransactionsUseCase(
            repository: context.read<TransactionRepository>(),
          ),
        ),
        
        // 라우팅에 필요한 글로벌 ViewModel들
        ChangeNotifierProvider<NavigationViewModel>(
          create: (context) => NavigationViewModel(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Lifetime Ledger',
        routerConfig: router,
      ),
    );
  }
}
```

## 화면별 Provider 설정과 라우팅

### 1. 기본 Screen 패턴
```dart
class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
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
      appBar: AppBar(title: const Text('거래 내역')),
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          return ListView.builder(
            itemCount: viewModel.transactions.length,
            itemBuilder: (context, index) {
              return TransactionCard(
                transaction: viewModel.transactions[index],
                onTap: () {
                  // ViewModel에서 네비게이션 처리
                  viewModel.navigateToDetail(
                    context, 
                    viewModel.transactions[index].id,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/transactions/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 2. 파라미터가 있는 Screen
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

class TransactionDetailView extends StatelessWidget {
  const TransactionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionDetailViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.transaction == null) {
          return const Scaffold(
            body: Center(child: Text('거래를 찾을 수 없습니다.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('거래 상세'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => viewModel.navigateToEdit(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => viewModel.deleteTransaction(context),
              ),
            ],
          ),
          body: TransactionDetailContent(
            transaction: viewModel.transaction!,
          ),
        );
      },
    );
  }
}
```

## ViewModel에서 네비게이션 처리

### 1. NavigationMixin 생성
```dart
mixin NavigationMixin {
  void navigateTo(BuildContext context, String path) {
    context.go(path);
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  void navigateAndReplace(BuildContext context, String path) {
    context.pushReplacement(path);
  }

  Future<T?> navigateModal<T>(BuildContext context, String path) {
    return context.push<T>(path);
  }
}
```

### 2. ViewModel에서 네비게이션 사용
```dart
class TransactionViewModel extends ChangeNotifier with NavigationMixin {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase;

  List<Transaction> _transactions = [];
  
  List<Transaction> get transactions => _transactions;

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

### 3. 네비게이션과 상태 관리 연동
```dart
class TransactionDetailViewModel extends ChangeNotifier with NavigationMixin {
  final String transactionId;
  final GetTransactionUseCase _getTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;

  TransactionDetailViewModel({
    required this.transactionId,
    required GetTransactionUseCase getTransactionUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
  }) : _getTransactionUseCase = getTransactionUseCase,
       _deleteTransactionUseCase = deleteTransactionUseCase;

  Transaction? _transaction;
  bool _isLoading = false;

  Transaction? get transaction => _transaction;
  bool get isLoading => _isLoading;

  Future<void> loadTransaction() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getTransactionUseCase(transactionId);
    
    result.when(
      success: (transaction) {
        _transaction = transaction;
        _isLoading = false;
        notifyListeners();
      },
      error: (failure) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void navigateToEdit(BuildContext context) {
    navigateTo(context, '/transactions/$transactionId/edit');
  }

  Future<void> deleteTransaction(BuildContext context) async {
    final confirmed = await _showDeleteConfirmation(context);
    if (!confirmed) return;

    final result = await _deleteTransactionUseCase(transactionId);
    
    result.when(
      success: (_) {
        // 삭제 성공 시 목록으로 돌아가기
        navigateAndReplace(context, '/transactions');
      },
      error: (failure) {
        // 에러 처리
        _showErrorSnackbar(context, failure.message);
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('거래 삭제'),
        content: const Text('이 거래를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

## 중첩 라우팅과 Provider

### 1. ShellRoute 사용
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
        ),
      ],
    ),
  ],
);
```

### 2. MainLayout에서 글로벌 Provider 관리
```dart
class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 레이아웃 레벨에서 필요한 ViewModel들
        ChangeNotifierProvider(
          create: (context) => NavigationViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeViewModel(),
        ),
      ],
      child: Scaffold(
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
      ),
    );
  }
}
```

## 라우트 가드와 인증

### 1. 인증 가드
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

### 2. 권한 가드
```dart
GoRoute(
  path: '/admin',
  builder: (context, state) => const AdminScreen(),
  redirect: (context, state) {
    final authViewModel = context.read<AuthViewModel>();
    if (!authViewModel.isAdmin) {
      return '/'; // 권한 없으면 홈으로
    }
    return null;
  },
)
```

## 딥링크와 상태 복원

### 1. 딥링크 처리
```dart
GoRoute(
  path: '/transactions/:id',
  builder: (context, state) {
    final transactionId = state.pathParameters['id']!;
    final queryParams = state.queryParameters;
    
    return TransactionDetailScreen(
      transactionId: transactionId,
      highlightField: queryParams['highlight'],
    );
  },
)

// 사용 예시: /transactions/123?highlight=amount
```

### 2. 상태 복원을 위한 ViewModel
```dart
class DeeplinkViewModel extends ChangeNotifier {
  String? _pendingRoute;
  
  String? get pendingRoute => _pendingRoute;

  void setPendingRoute(String route) {
    _pendingRoute = route;
    notifyListeners();
  }

  void clearPendingRoute() {
    _pendingRoute = null;
    notifyListeners();
  }

  void handlePendingNavigation(BuildContext context) {
    if (_pendingRoute != null) {
      context.go(_pendingRoute!);
      clearPendingRoute();
    }
  }
}
```

## 에러 처리

### 1. 404 페이지
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

## Best Practices

### 1. Provider와 라우팅 분리
- 라우팅 로직은 ViewModel에 캡슐화
- NavigationMixin으로 공통 네비게이션 로직 추상화
- 각 Screen에서 독립적인 Provider 설정

### 2. 상태 관리와 네비게이션
- ViewModel에서 네비게이션 후 상태 업데이트
- 에러 발생 시 적절한 네비게이션 처리
- 성공 시 자동 네비게이션

### 3. 성능 최적화
- 필요한 경우에만 ViewModel 생성
- 라우트별 독립적인 Provider 설정
- 불필요한 리빌드 방지

### 4. 사용자 경험
- 적절한 로딩 상태 표시
- 에러 상황에서 명확한 피드백
- 직관적인 네비게이션 흐름

## 체크리스트

### 라우트 설정
- [ ] GoRouter 기본 설정
- [ ] 중첩 라우트 구조
- [ ] 파라미터 전달 방식

### Provider 통합
- [ ] 화면별 ChangeNotifierProvider 설정
- [ ] 글로벌 Provider 설정
- [ ] ViewModel에서 네비게이션 처리

### 가드 및 보안
- [ ] 인증 가드 구현
- [ ] 권한 가드 구현
- [ ] 적절한 리다이렉션

### 에러 처리
- [ ] 404 페이지 구현
- [ ] 에러 상태 처리
- [ ] 사용자 피드백 제공