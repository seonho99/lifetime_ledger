# GoRouter 설정

## 라우터 구성

### 1. 기본 구조
```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
```

### 2. 중첩 라우트
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
          builder: (context, state) => const TransactionListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddTransactionScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => TransactionDetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
```

## 라우트 정의 규칙

### 1. 경로 네이밍
```
✅ 올바른 예시:
- /login
- /home
- /transactions
- /transactions/add
- /transactions/:id
- /settings/profile

❌ 잘못된 예시:
- /Login
- /Home
- /transactions/add/
- /transactions/add-transaction
```

### 2. 파라미터 전달
```dart
// 경로 파라미터
GoRoute(
  path: '/transactions/:id',
  builder: (context, state) => TransactionDetailScreen(
    id: state.pathParameters['id']!,
  ),
),

// 쿼리 파라미터
GoRoute(
  path: '/transactions',
  builder: (context, state) => TransactionListScreen(
    filter: state.queryParameters['filter'],
  ),
),
```

## 네비게이션

### 1. 기본 네비게이션
```dart
// 이동
context.go('/transactions');

// 푸시
context.push('/transactions/add');

// 뒤로가기
context.pop();

// 홈으로
context.go('/');
```

### 2. 파라미터와 함께 네비게이션
```dart
// 경로 파라미터
context.go('/transactions/123');

// 쿼리 파라미터
context.go('/transactions?filter=income');

// 추가 데이터
context.go('/transactions', extra: {'data': data});
```

## 라우트 가드

### 1. 인증 가드
```dart
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = AuthService.isLoggedIn;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }

    if (isLoggedIn && isLoginRoute) {
      return '/home';
    }

    return null;
  },
  routes: [...],
);
```

### 2. 권한 가드
```dart
final router = GoRouter(
  redirect: (context, state) {
    final isAdmin = AuthService.isAdmin;
    final isAdminRoute = state.matchedLocation.startsWith('/admin');

    if (isAdminRoute && !isAdmin) {
      return '/home';
    }

    return null;
  },
  routes: [...],
);
```

## 에러 처리

### 1. 404 처리
```dart
final router = GoRouter(
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [...],
);
```

### 2. 에러 페이지
```dart
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('페이지를 찾을 수 없습니다.'),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Best Practices

### 1. 라우트 구성
- 명확한 경로 구조
- 중첩 라우트 적절히 사용
- 일관된 네이밍 규칙

### 2. 네비게이션
- 적절한 네비게이션 메서드 사용
- 파라미터 전달 방식 통일
- 딥링크 지원

### 3. 상태 관리
- 라우트 상태와 앱 상태 분리
- 적절한 리다이렉션 처리
- 에러 상태 처리

### 4. 성능
- 라우트 지연 로딩
- 불필요한 리빌드 방지
- 메모리 누수 방지

## 체크리스트

### 1. 라우트 구성
- [ ] 모든 화면에 대한 라우트 정의
- [ ] 중첩 라우트 적절히 사용
- [ ] 파라미터 전달 방식 정의

### 2. 네비게이션
- [ ] 적절한 네비게이션 메서드 사용
- [ ] 딥링크 지원
- [ ] 뒤로가기 처리

### 3. 보안
- [ ] 인증 가드 구현
- [ ] 권한 가드 구현
- [ ] 민감한 라우트 보호

### 4. 에러 처리
- [ ] 404 페이지 구현
- [ ] 에러 상태 처리
- [ ] 사용자 피드백 제공
