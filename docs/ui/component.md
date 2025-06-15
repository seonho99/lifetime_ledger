# 공통 컴포넌트 작성 가이드

## 1. 기본 구조

### 1. StatelessWidget
```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(text),
    );
  }
}
```

### 2. StatefulWidget
```dart
class CustomTextField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const CustomTextField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
      ),
      onChanged: widget.onChanged,
    );
  }
}
```

## 2. 컴포넌트 유형

### 1. 입력 컴포넌트
```dart
class AmountInput extends StatelessWidget {
  final double? value;
  final ValueChanged<double> onChanged;
  final String? errorText;

  const AmountInput({
    super.key,
    this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '금액',
        prefixText: '₩ ',
        errorText: errorText,
      ),
      onChanged: (value) {
        final amount = double.tryParse(value);
        if (amount != null) {
          onChanged(amount);
        }
      },
    );
  }
}
```

### 2. 표시 컴포넌트
```dart
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          transaction.type == TransactionType.income
              ? Icons.arrow_upward
              : Icons.arrow_downward,
          color: transaction.type == TransactionType.income
              ? Colors.green
              : Colors.red,
        ),
        title: Text(transaction.title),
        subtitle: Text(transaction.category),
        trailing: Text(
          '₩${transaction.amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: transaction.type == TransactionType.income
                ? Colors.green
                : Colors.red,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
```

### 3. 레이아웃 컴포넌트
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobile;
        } else if (constraints.maxWidth < 1200) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}
```

## 3. 컴포넌트 설계 원칙

### 1. 단일 책임
- 하나의 컴포넌트는 하나의 역할만 수행
- 재사용 가능한 작은 단위로 분리
- 명확한 인터페이스 정의

### 2. Props 설계
- 필수 props와 선택적 props 구분
- 타입 안전성 보장
- 기본값 제공

### 3. 상태 관리
- 상태는 최소한으로 유지
- 부모 컴포넌트와의 통신
- 상태 변경의 예측 가능성

## 4. Best Practices

### 1. 성능
```dart
// const 생성자 사용
const CustomButton({
  required this.text,
  required this.onPressed,
});

// 불필요한 리빌드 방지
class _CustomWidgetState extends State<CustomWidget> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: // ...
    );
  }
}
```

### 2. 접근성
```dart
// 시맨틱 레이블 추가
Semantics(
  label: '결제 버튼',
  button: true,
  child: ElevatedButton(
    onPressed: () {},
    child: const Text('결제'),
  ),
);

// 키보드 포커스
Focus(
  autofocus: true,
  child: TextField(
    decoration: const InputDecoration(
      labelText: '검색',
    ),
  ),
);
```

### 3. 테스트
```dart
// 위젯 테스트
testWidgets('CustomButton test', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CustomButton(
        text: 'Test',
        onPressed: () {},
      ),
    ),
  );

  expect(find.text('Test'), findsOneWidget);
  await tester.tap(find.byType(CustomButton));
  await tester.pump();
});
```

## 5. 체크리스트

### 1. 기본 구조
- [ ] 명확한 책임
- [ ] 적절한 props
- [ ] 상태 관리
- [ ] 에러 처리

### 2. 성능
- [ ] const 생성자
- [ ] 리빌드 최적화
- [ ] 메모리 관리
- [ ] 이미지 최적화

### 3. 접근성
- [ ] 시맨틱 레이블
- [ ] 키보드 네비게이션
- [ ] 스크린 리더
- [ ] 색상 대비

### 4. 테스트
- [ ] 단위 테스트
- [ ] 위젯 테스트
- [ ] 스냅샷 테스트
- [ ] 접근성 테스트
