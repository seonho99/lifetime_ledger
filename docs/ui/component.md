# 🧩 공통 컴포넌트 설계 가이드

---

## ✅ 설계 철학

### 1. **단일 기능 원칙**
- 공통 컴포넌트는 가능한 한 **단일 기능**만 수행해야 한다.
- 다만 **필터**, **공통 시트**, **리스트 팝업**과 같은 **다중 재사용 가능한 컴포넌트**는 예외로 한다.

### 2. **UI 재사용 중심**
- **재사용되지 않는 UI는 공통 컴포넌트가 아닌**, 해당 기능의 하위 위젯일 뿐이다.
- **재사용 가능한 UI 요소**만 **공통 컴포넌트**로 분리해야 한다.

### 3. **상위 위젯의 제어권 보장**
- 공통 컴포넌트는 **상위 위젯**에서 의도한 대로 **크기**와 **여백**을 **유연하게 제어**할 수 있도록 설계해야 하며,  
  **해당 컴포넌트의 사이즈**나 **외부 여백**을 컴포넌트 내에서 고정하지 않도록 한다.

---

## ✅ 설계 원칙

### 1. **기능 독립성**
- 각 **컴포넌트**는 **단일 책임**을 가져야 한다. 하나의 **컴포넌트**는 하나의 **기능**만 처리하도록 설계한다.
- **상태**는 **상위 ViewModel**에서 관리하고, 컴포넌트는 **UI 렌더링**만 담당한다.
- **상태 관리**는 **상위 ViewModel**에서 하도록 하여 컴포넌트의 **재사용성과 독립성**을 유지한다.

#### 예시:
- **❌ 잘못된 예시**: 컴포넌트에서 **상태**를 **관리**하는 경우 (버튼 컴포넌트에서 `isEnabled` 상태 처리 등)
- **✅ 올바른 예시**: 컴포넌트는 상태를 처리하지 않고, **상위 ViewModel**에서 **상태 관리**하여 **UI만 렌더링**하는 방식으로 설계한다.

---

### 2. **상위 위젯과의 유연성 유지**
- **컴포넌트**는 **상위 위젯**에서 크기와 여백을 제어할 수 있도록 설계해야 한다.
- 외부에서 **`SizedBox`**나 **다른 위젯**으로 **감싸서 크기와 여백을 제어**할 수 있도록 한다.
- 필요에 따라 **외부에서 크기값 파라미터**를 사용할 수 있도록 유연성을 제공하지만, 기본적으로 **`nullable`**로 처리한다.

#### 예시:
- **❌ 잘못된 예시**: 컴포넌트 내에서 **고정된 크기**나 **고정된 여백**을 설정한 경우.
- **✅ 올바른 예시**: 부모 위젯에서 컴포넌트의 **크기**와 **여백**을 **유동적으로 제어**할 수 있도록 한다. 컴포넌트를 고정된 수치로 제어해야 한다면 되도록 사용하는 View에서 컴포넌트를 생성할 때 위젯을 감싸서 사용하는 방식을 우선으로 한다. (크기 조정은 `SizedBox`위젯으로 감싸기)

---

### 3. **UI 일관성 유지**
- 공통 컴포넌트는 **디자인 시스템**에 맞게 **일관된 스타일**을 유지해야 한다.
- **상수화된 값**(여백, 버튼 크기, 색상 등)을 사용하여 **일관된 UI**를 구현하고자, **기본값**은 컴포넌트 내에서 처리한다.
- 이미지, 스타일이나 색상 등의 요소가 자주 바뀌는 요소는 필요 요소만 **주입**할 수 있도록 한다. (이미지의 url이나 스타일의 color값만 파라미터 등으로 생성)

#### 예시:
- **❌ 잘못된 예시**: 스타일을 **하드코딩**하거나, **상수화되지 않은 스타일**을 직접 사용한 경우.
- **✅ 올바른 예시**: 스타일은 **상수화**하여 일관성 있는 **UI**를 유지하고, **외부에서 주입**할 수 있도록 설계한다.

---

### 4. **재사용 가능성**
- **공통 컴포넌트는 재사용 가능한 단위**로 설계해야 한다.
- **반복되는 UI** 요소를 **하나의 공통 컴포넌트**로 정의해두면 리스트를 표현할 때나 그리드 형태의 반복 요소에서 정의된 컴포넌트 하나만을 재사용할 수 있다.

#### 예시:
- **❌ 잘못된 예시**: UI 요소를 **하드코딩**하여 재사용 불가
- **✅ 올바른 예시**: **리스트 항목** 같은 **반복되는 UI 요소**를 **공통 컴포넌트화**하여 여러 화면에서 **재사용 가능**하게 설계한다.

---

## ✅ 컴포넌트 예시

### 기본 컴포넌트

```dart
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final bool isLoading;
  
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      ),
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(text),
    );
  }
}
```

### 재사용 가능한 카드 컴포넌트

```dart
class TransactionCard extends StatelessWidget {
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final VoidCallback? onTap;
  
  const TransactionCard({
    super.key,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(category),
        trailing: Text('₩${amount.toStringAsFixed(0)}'),
        onTap: onTap,
      ),
    );
  }
}
```

---
