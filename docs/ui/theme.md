# 테마 설정 가이드

## 1. 기본 테마 설정

### 1. ColorScheme
```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  );
}
```

### 2. Typography
```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
```

## 2. 커스텀 테마

### 1. 색상 정의
```dart
class AppColors {
  static const primary = Color(0xFF2196F3);
  static const secondary = Color(0xFF03DAC6);
  static const error = Color(0xFFB00020);
  
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFF000000);
  static const onBackground = Color(0xFF000000);
  static const onSurface = Color(0xFF000000);
  static const onError = Color(0xFFFFFFFF);
}
```

### 2. 텍스트 스타일
```dart
class AppTextStyles {
  static const title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
  );

  static const subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );
}
```

### 3. 컴포넌트 테마
```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.title,
      bodyLarge: AppTextStyles.body,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
  );
}
```

## 3. 다크 모드

### 1. 다크 모드 색상
```dart
class AppColors {
  static const darkPrimary = Color(0xFF90CAF9);
  static const darkSecondary = Color(0xFF03DAC6);
  static const darkError = Color(0xFFCF6679);
  
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkOnPrimary = Color(0xFF000000);
  static const darkOnSecondary = Color(0xFF000000);
  static const darkOnBackground = Color(0xFFFFFFFF);
  static const darkOnSurface = Color(0xFFFFFFFF);
  static const darkOnError = Color(0xFF000000);
}
```

### 2. 다크 모드 테마
```dart
class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkPrimary,
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.title,
      bodyLarge: AppTextStyles.body,
    ).apply(
      bodyColor: AppColors.darkOnBackground,
      displayColor: AppColors.darkOnBackground,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
      ),
    ),
  );
}
```

## 4. 테마 적용

### 1. 앱 레벨 적용
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
```

### 2. 테마 사용
```dart
class CustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.background,
      child: Text(
        'Hello',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onBackground,
        ),
      ),
    );
  }
}
```

## 5. Best Practices

### 1. 테마 구성
- Material 3 디자인 시스템 준수
- 일관된 색상 팔레트 사용
- 명확한 타이포그래피 계층 구조
- 컴포넌트별 테마 정의

### 2. 접근성
- 충분한 색상 대비
- 적절한 텍스트 크기
- 다크 모드 지원
- 스크린 리더 지원

### 3. 성능
- 테마 객체 재사용
- 불필요한 테마 복제 방지
- 효율적인 리소스 관리

## 6. 체크리스트

### 1. 기본 설정
- [ ] Material 3 적용
- [ ] 색상 스키마 정의
- [ ] 타이포그래피 설정
- [ ] 컴포넌트 테마 정의

### 2. 다크 모드
- [ ] 다크 모드 색상 정의
- [ ] 다크 모드 테마 설정
- [ ] 자동 전환 지원
- [ ] 수동 전환 지원

### 3. 접근성
- [ ] 색상 대비 검사
- [ ] 텍스트 크기 검사
- [ ] 스크린 리더 테스트
- [ ] 키보드 네비게이션

### 4. 성능
- [ ] 테마 객체 최적화
- [ ] 리소스 관리
- [ ] 메모리 사용량
- [ ] 빌드 성능 