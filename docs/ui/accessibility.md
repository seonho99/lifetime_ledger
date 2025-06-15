# 접근성 가이드

## 1. 시맨틱 레이블

### 1. 기본 시맨틱
```dart
class SemanticExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '결제 버튼',
      button: true,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('결제'),
      ),
    );
  }
}
```

### 2. 복합 시맨틱
```dart
class ComplexSemanticExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '거래 내역 카드',
      child: Card(
        child: Column(
          children: [
            Semantics(
              label: '거래 금액: 10,000원',
              child: Text('₩10,000'),
            ),
            Semantics(
              label: '거래 날짜: 2024년 3월 15일',
              child: Text('2024-03-15'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 2. 키보드 네비게이션

### 1. 포커스 관리
```dart
class FocusExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Focus(
          autofocus: true,
          child: TextField(
            decoration: const InputDecoration(
              labelText: '검색',
            ),
          ),
        ),
        Focus(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('검색'),
          ),
        ),
      ],
    );
  }
}
```

### 2. 키보드 단축키
```dart
class KeyboardShortcutExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          // 검색 실행
        }
      },
      child: TextField(
        decoration: const InputDecoration(
          labelText: '검색 (Enter 키로 검색)',
        ),
      ),
    );
  }
}
```

## 3. 스크린 리더

### 1. 이미지 설명
```dart
class ImageDescriptionExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '거래 내역 차트',
      child: Image.asset(
        'assets/chart.png',
        semanticLabel: '월별 수입 지출 차트',
      ),
    );
  }
}
```

### 2. 동적 콘텐츠
```dart
class DynamicContentExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '거래 금액',
      value: '10,000원',
      child: Text('₩10,000'),
    );
  }
}
```

## 4. 색상 및 대비

### 1. 색상 대비
```dart
class ColorContrastExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Text(
        '중요 메시지',
        style: TextStyle(
          color: Colors.black, // 충분한 대비
          fontSize: 16,
        ),
      ),
    );
  }
}
```

### 2. 색상 의존성
```dart
class ColorDependencyExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green,
          semanticLabel: '성공',
        ),
        Text(
          '거래 완료',
          style: TextStyle(
            color: Colors.black, // 색상에 의존하지 않는 텍스트
          ),
        ),
      ],
    );
  }
}
```

## 5. Best Practices

### 1. 기본 원칙
- 명확한 시맨틱 레이블
- 키보드 네비게이션 지원
- 충분한 색상 대비
- 스크린 리더 지원

### 2. 사용자 경험
- 일관된 네비게이션
- 명확한 피드백
- 적절한 타이밍
- 오류 처리

### 3. 테스트
- 스크린 리더 테스트
- 키보드 네비게이션 테스트
- 색상 대비 테스트
- 사용자 테스트

## 6. 체크리스트

### 1. 시맨틱
- [ ] 모든 상호작용 요소에 시맨틱 레이블
- [ ] 이미지에 대체 텍스트
- [ ] 동적 콘텐츠 업데이트
- [ ] 복합 위젯 설명

### 2. 키보드
- [ ] 모든 기능 키보드 접근
- [ ] 포커스 순서
- [ ] 키보드 단축키
- [ ] 포커스 표시

### 3. 시각
- [ ] 색상 대비
- [ ] 텍스트 크기
- [ ] 이미지 대체
- [ ] 애니메이션 제어

### 4. 테스트
- [ ] 스크린 리더
- [ ] 키보드 네비게이션
- [ ] 색상 대비
- [ ] 사용자 테스트 