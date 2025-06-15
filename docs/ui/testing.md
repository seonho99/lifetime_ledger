# UI 테스트 가이드

## 1. 위젯 테스트

### 1. 기본 위젯 테스트
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```

### 2. 폼 테스트
```dart
void main() {
  testWidgets('Form validation test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 필수 필드 비워두기
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('필수 항목입니다'), findsOneWidget);

    // 필드 채우기
    await tester.enterText(find.byType(TextField).first, 'Test');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('필수 항목입니다'), findsNothing);
  });
}
```

## 2. 통합 테스트

### 1. 기본 통합 테스트
```dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Complete transaction flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 거래 추가
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 거래 정보 입력
      await tester.enterText(find.byType(TextField).first, '10000');
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 거래 확인
      expect(find.text('₩10,000'), findsOneWidget);
    });
  });
}
```

### 2. 네비게이션 테스트
```dart
void main() {
  testWidgets('Navigation test', (tester) async {
    await tester.pumpWidget(const MyApp());

    // 홈 화면 확인
    expect(find.text('홈'), findsOneWidget);

    // 설정 화면으로 이동
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // 설정 화면 확인
    expect(find.text('설정'), findsOneWidget);
  });
}
```

## 3. 골든 테스트

### 1. 기본 골든 테스트
```dart
void main() {
  testWidgets('Golden test', (tester) async {
    await tester.pumpWidget(const MyApp());
    await expectLater(
      find.byType(MyApp),
      matchesGoldenFile('goldens/app.png'),
    );
  });
}
```

### 2. 다크 모드 테스트
```dart
void main() {
  testWidgets('Dark mode golden test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        theme: ThemeData.dark(),
        home: MyApp(),
      ),
    );
    await expectLater(
      find.byType(MyApp),
      matchesGoldenFile('goldens/app_dark.png'),
    );
  });
}
```

## 4. 성능 테스트

### 1. 프레임 드롭 테스트
```dart
void main() {
  testWidgets('Performance test', (tester) async {
    await tester.pumpWidget(const MyApp());

    // 스크롤 성능 테스트
    for (int i = 0; i < 100; i++) {
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -300),
        3000,
      );
      await tester.pumpAndSettle();
    }

    // 프레임 드롭 확인
    final timeline = await tester.traceTimeline();
    expect(timeline, isNotNull);
  });
}
```

### 2. 메모리 테스트
```dart
void main() {
  testWidgets('Memory test', (tester) async {
    await tester.pumpWidget(const MyApp());

    // 메모리 사용량 측정
    final memory = await tester.traceMemory();
    expect(memory, isNotNull);
  });
}
```

## 5. Best Practices

### 1. 테스트 구조
- 명확한 테스트 설명
- 독립적인 테스트
- 재사용 가능한 테스트
- 유지보수 가능한 구조

### 2. 테스트 커버리지
- 중요 기능 테스트
- 엣지 케이스 테스트
- 에러 케이스 테스트
- 성능 테스트

### 3. 테스트 환경
- 일관된 환경
- 격리된 테스트
- 빠른 실행
- 안정적인 결과

## 6. 체크리스트

### 1. 단위 테스트
- [ ] 위젯 테스트
- [ ] 상태 테스트
- [ ] 이벤트 테스트
- [ ] 에러 테스트

### 2. 통합 테스트
- [ ] 화면 전환
- [ ] 데이터 흐름
- [ ] 사용자 입력
- [ ] API 통신

### 3. UI 테스트
- [ ] 레이아웃
- [ ] 스타일
- [ ] 애니메이션
- [ ] 접근성

### 4. 성능 테스트
- [ ] 프레임 드롭
- [ ] 메모리 사용
- [ ] 배터리 사용
- [ ] 네트워크 사용 