# 반응형 디자인 가이드

## 1. 기본 레이아웃

### 1. LayoutBuilder
```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const MobileLayout();
        } else if (constraints.maxWidth < 1200) {
          return const TabletLayout();
        } else {
          return const DesktopLayout();
        }
      },
    );
  }
}
```

### 2. MediaQuery
```dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Container(
      width: screenSize.width * 0.8,
      height: isLandscape ? screenSize.height * 0.9 : screenSize.height * 0.7,
      child: // ...
    );
  }
}
```

## 2. 반응형 컴포넌트

### 1. 그리드 레이아웃
```dart
class ResponsiveGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 3;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Card(
              child: Center(
                child: Text('Item $index'),
              ),
            );
          },
        );
      },
    );
  }
}
```

### 2. 반응형 텍스트
```dart
class ResponsiveText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize;
        if (constraints.maxWidth < 600) {
          fontSize = 16;
        } else if (constraints.maxWidth < 1200) {
          fontSize = 20;
        } else {
          fontSize = 24;
        }

        return Text(
          'Responsive Text',
          style: TextStyle(fontSize: fontSize),
        );
      },
    );
  }
}
```

## 3. 화면 크기별 레이아웃

### 1. 모바일 레이아웃
```dart
class MobileLayout extends StatelessWidget {
  const MobileLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Layout'),
      ),
      body: ListView(
        children: [
          // 모바일에 최적화된 위젯들
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
```

### 2. 태블릿 레이아웃
```dart
class TabletLayout extends StatelessWidget {
  const TabletLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablet Layout'),
      ),
      body: Row(
        children: [
          // 사이드바
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          // 메인 컨텐츠
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  child: Center(
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. 데스크톱 레이아웃
```dart
class DesktopLayout extends StatelessWidget {
  const DesktopLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desktop Layout'),
      ),
      body: Row(
        children: [
          // 사이드바
          NavigationRail(
            extended: true,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          // 메인 컨텐츠
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  child: Center(
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## 4. Best Practices

### 1. 레이아웃 설계
- 모바일 퍼스트 접근
- 유동적인 그리드 시스템
- 적절한 여백과 간격
- 터치 타겟 크기 고려

### 2. 성능
- 불필요한 리빌드 방지
- 이미지 최적화
- 레이아웃 계산 최적화
- 메모리 사용량 관리

### 3. 접근성
- 터치 타겟 크기
- 키보드 네비게이션
- 스크린 리더 지원
- 색상 대비

## 5. 체크리스트

### 1. 기본 설정
- [ ] 화면 크기 감지
- [ ] 방향 감지
- [ ] 레이아웃 전환
- [ ] 반응형 컴포넌트

### 2. 레이아웃
- [ ] 모바일 레이아웃
- [ ] 태블릿 레이아웃
- [ ] 데스크톱 레이아웃
- [ ] 그리드 시스템

### 3. 성능
- [ ] 리빌드 최적화
- [ ] 이미지 최적화
- [ ] 레이아웃 계산
- [ ] 메모리 관리

### 4. 테스트
- [ ] 다양한 화면 크기
- [ ] 다양한 방향
- [ ] 터치 인터랙션
- [ ] 키보드 네비게이션 