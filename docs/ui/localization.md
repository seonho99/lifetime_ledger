# 다국어 지원 가이드

## 1. 기본 설정

### 1. pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0
```

### 2. 앱 설정
```dart
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // 영어
        Locale('ko'), // 한국어
        Locale('ja'), // 일본어
      ],
      home: const HomeScreen(),
    );
  }
}
```

## 2. 번역 파일

### 1. arb 파일
```json
// app_en.arb
{
  "appTitle": "Lifetime Ledger",
  "income": "Income",
  "expense": "Expense",
  "amount": "Amount",
  "date": "Date",
  "category": "Category",
  "note": "Note",
  "save": "Save",
  "cancel": "Cancel",
  "@appTitle": {
    "description": "The title of the application"
  }
}

// app_ko.arb
{
  "appTitle": "평생 가계부",
  "income": "수입",
  "expense": "지출",
  "amount": "금액",
  "date": "날짜",
  "category": "카테고리",
  "note": "메모",
  "save": "저장",
  "cancel": "취소"
}
```

### 2. l10n.yaml
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

## 3. 번역 사용

### 1. 기본 사용
```dart
class LocalizedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(AppLocalizations.of(context)!.appTitle),
        Text(AppLocalizations.of(context)!.income),
        Text(AppLocalizations.of(context)!.expense),
      ],
    );
  }
}
```

### 2. 매개변수 사용
```dart
// app_en.arb
{
  "welcome": "Welcome, {name}!",
  "@welcome": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}

// app_ko.arb
{
  "welcome": "{name}님, 환영합니다!"
}

// 사용
Text(AppLocalizations.of(context)!.welcome('John'))
```

## 4. 날짜 및 숫자 포맷

### 1. 날짜 포맷
```dart
class DateFormatExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context);
    
    return Text(
      DateFormat.yMMMd(locale.languageCode).format(now),
    );
  }
}
```

### 2. 숫자 포맷
```dart
class NumberFormatExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final amount = 1000000;
    final locale = Localizations.localeOf(context);
    
    return Text(
      NumberFormat.currency(
        locale: locale.languageCode,
        symbol: '₩',
      ).format(amount),
    );
  }
}
```

## 5. Best Practices

### 1. 번역 관리
- 일관된 키 이름
- 명확한 설명
- 컨텍스트 제공
- 주석 활용

### 2. 성능
- 필요한 번역만 로드
- 캐시 활용
- 메모리 관리
- 로딩 최적화

### 3. 테스트
- 모든 언어 테스트
- 포맷 테스트
- 레이아웃 테스트
- 성능 테스트

## 6. 체크리스트

### 1. 기본 설정
- [ ] 필요한 패키지 추가
- [ ] 로케일 설정
- [ ] 델리게이트 설정
- [ ] 지원 언어 설정

### 2. 번역 파일
- [ ] arb 파일 생성
- [ ] 템플릿 설정
- [ ] 번역 추가
- [ ] 설명 추가

### 3. 구현
- [ ] 번역 사용
- [ ] 포맷 적용
- [ ] 동적 콘텐츠
- [ ] 폴백 처리

### 4. 테스트
- [ ] 모든 언어
- [ ] 포맷
- [ ] 레이아웃
- [ ] 성능 