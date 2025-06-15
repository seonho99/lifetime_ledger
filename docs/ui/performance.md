# 성능 최적화 가이드

## 1. 리빌드 최적화

### 1. const 생성자
```dart
class OptimizedWidget extends StatelessWidget {
  const OptimizedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Hello'),
        Icon(Icons.star),
      ],
    );
  }
}
```

### 2. RepaintBoundary
```dart
class OptimizedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1000,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: ListTile(
            title: Text('Item $index'),
          ),
        );
      },
    );
  }
}
```

## 2. 이미지 최적화

### 1. 이미지 캐싱
```dart
class OptimizedImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: 'https://example.com/image.jpg',
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
```

### 2. 이미지 크기 최적화
```dart
class OptimizedImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://example.com/image.jpg',
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      cacheWidth: 200, // 2x for retina displays
      cacheHeight: 200,
    );
  }
}
```

## 3. 리스트 최적화

### 1. ListView.builder
```dart
class OptimizedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1000,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
        );
      },
    );
  }
}
```

### 2. GridView.builder
```dart
class OptimizedGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: 1000,
      itemBuilder: (context, index) {
        return Card(
          child: Center(
            child: Text('Item $index'),
          ),
        );
      },
    );
  }
}
```

## 4. 메모리 최적화

### 1. 이미지 메모리 관리
```dart
class ImageMemoryManager extends StatefulWidget {
  @override
  State<ImageMemoryManager> createState() => _ImageMemoryManagerState();
}

class _ImageMemoryManagerState extends State<ImageMemoryManager> {
  final List<ImageProvider> _images = [];

  @override
  void dispose() {
    for (var image in _images) {
      image.evict();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 100,
      itemBuilder: (context, index) {
        final image = NetworkImage('https://example.com/image$index.jpg');
        _images.add(image);
        return Image(image: image);
      },
    );
  }
}
```

### 2. 컨트롤러 관리
```dart
class ControllerManager extends StatefulWidget {
  @override
  State<ControllerManager> createState() => _ControllerManagerState();
}

class _ControllerManagerState extends State<ControllerManager> {
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: _controller),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: 100,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Item $index'),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## 5. Best Practices

### 1. 성능 최적화
- 불필요한 리빌드 방지
- 이미지 최적화
- 메모리 관리
- 네트워크 최적화

### 2. 코드 구조
- 위젯 분리
- 상태 관리
- 비동기 처리
- 에러 처리

### 3. 테스트
- 성능 테스트
- 메모리 테스트
- 네트워크 테스트
- 사용자 경험 테스트

## 6. 체크리스트

### 1. 리빌드
- [ ] const 생성자 사용
- [ ] RepaintBoundary 적용
- [ ] 위젯 분리
- [ ] 상태 관리

### 2. 이미지
- [ ] 이미지 캐싱
- [ ] 크기 최적화
- [ ] 메모리 관리
- [ ] 로딩 처리

### 3. 리스트
- [ ] ListView.builder 사용
- [ ] GridView.builder 사용
- [ ] 아이템 재사용
- [ ] 스크롤 최적화

### 4. 메모리
- [ ] 리소스 해제
- [ ] 이미지 메모리
- [ ] 컨트롤러 관리
- [ ] 캐시 관리 