# UI 설계 원칙

## 1. Material Design 3

### 기본 원칙
- Material You 테마 시스템 활용
- 동적 색상 시스템 적용
- 접근성 고려
- 반응형 디자인

### 컴포넌트 사용
```dart
// Material 3 컴포넌트 사용
Scaffold(
  appBar: AppBar(
    title: const Text('Material 3'),
    scrolledUnderElevation: 0,
  ),
  body: ListView(
    children: [
      Card(
        child: ListTile(
          title: const Text('Material 3 Card'),
          subtitle: const Text('Material 3 ListTile'),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ),
      ),
    ],
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),
);
```

## 2. 레이아웃 원칙

### 1. 반응형 레이아웃
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return const MobileLayout();
    } else {
      return const DesktopLayout();
    }
  },
);
```

### 2. 그리드 시스템
```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.0,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
  ),
  itemBuilder: (context, index) => Card(
    child: Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // 그리드 아이템 내용
        ],
      ),
    ),
  ),
);
```

## 3. 타이포그래피

### 1. 텍스트 스타일
```dart
Text(
  '제목',
  style: Theme.of(context).textTheme.headlineMedium,
);

Text(
  '본문',
  style: Theme.of(context).textTheme.bodyLarge,
);

Text(
  '설명',
  style: Theme.of(context).textTheme.bodySmall,
);
```

### 2. 폰트 설정
```dart
ThemeData(
  textTheme: TextTheme(
    displayLarge: GoogleFonts.notoSans(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: GoogleFonts.notoSans(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
  ),
);
```

## 4. 색상 시스템

### 1. 테마 색상
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
);
```

### 2. 다크 모드
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
);
```

## 5. 애니메이션

### 1. 기본 애니메이션
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isExpanded ? 200 : 100,
  height: isExpanded ? 200 : 100,
  color: Colors.blue,
);
```

### 2. 페이지 전환
```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => const NewPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
);
```

## 6. 접근성

### 1. 시맨틱 레이블
```dart
Semantics(
  label: '결제 버튼',
  button: true,
  child: ElevatedButton(
    onPressed: () {},
    child: const Text('결제'),
  ),
);
```

### 2. 키보드 네비게이션
```dart
Focus(
  autofocus: true,
  child: TextField(
    decoration: const InputDecoration(
      labelText: '검색',
    ),
  ),
);
```

## 7. Best Practices

### 1. 성능 최적화
- const 생성자 사용
- 불필요한 리빌드 방지
- 이미지 최적화
- 레이아웃 최적화

### 2. 코드 구조
- 위젯 분리
- 재사용 가능한 컴포넌트
- 일관된 네이밍
- 주석 및 문서화

### 3. 테스트
- 위젯 테스트
- 스냅샷 테스트
- 접근성 테스트
- 성능 테스트

## 8. 체크리스트

### 1. 디자인 시스템
- [ ] Material Design 3 적용
- [ ] 일관된 색상 시스템
- [ ] 타이포그래피 시스템
- [ ] 컴포넌트 라이브러리

### 2. 레이아웃
- [ ] 반응형 디자인
- [ ] 그리드 시스템
- [ ] 여백 및 정렬
- [ ] 오버플로우 처리

### 3. 접근성
- [ ] 시맨틱 레이블
- [ ] 키보드 네비게이션
- [ ] 스크린 리더 지원
- [ ] 색상 대비

### 4. 성능
- [ ] 리빌드 최적화
- [ ] 이미지 최적화
- [ ] 애니메이션 성능
- [ ] 메모리 사용량
