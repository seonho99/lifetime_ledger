# 🧱 레이어별 책임 및 흐름 가이드

---

# ✅ 아키텍처 구조 배경

이 프로젝트는 기본적으로 **Provider + MVVM + Clean Architecture**를 기반으로 화면 구조를 설계합니다.

- **Provider**를 통해 의존성 주입과 상태 관리를 수행하고,
- **MVVM** 패턴을 통해 ViewModel(ChangeNotifier) 중심으로 상태를 관리하며,
- **Clean Architecture**를 통해 레이어별 책임을 명확히 구분합니다.

하지만 이 구조만으로는 화면/상태 흐름은 명확해지지만,  
**비즈니스 로직 처리(UseCase, Repository, DataSource)와 데이터 흐름에 대한 책임 구분은 명확히 설명되지 않습니다.**

따라서 이 문서에서는  
**Provider + MVVM 아키텍처 흐름을 보완하는 레이어 구분**을 추가하여,
- 각 계층의 책임을 명확히 하고,
- 데이터 흐름을 일관성 있게 유지하며,
- 비즈니스 로직이 올바른 위치에서 처리되도록 강제하는  
  기준을 제공합니다.

---

# 🏛️ 레이어 구조

### 1. Presentation Layer (MVVM)

- **UI 계층**입니다.
- **Screen**: ChangeNotifierProvider 설정 + StatelessWidget UI
- **ViewModel**: ChangeNotifier 기반 상태 관리, UseCase 호출
- **State**: freezed 기반 불변 상태 객체
- **Widget**: 재사용 가능한 UI 컴포넌트
- Consumer/Selector로 상태를 구독하고, ViewModel 메서드를 호출합니다.
- 직접 비즈니스 로직을 실행하거나 외부 데이터 통신을 호출하지 않습니다.

---

### 2. Domain Layer

- **비즈니스 로직 계층**입니다.
- **Entity**: 순수 도메인 모델 (Transaction, Category 등)
- **UseCase**: 비즈니스 규칙을 실행합니다.
- **Repository Interface**: 데이터 접근을 추상화합니다.
- Repository 인터페이스를 정의하고, 이 인터페이스만 의존합니다.
- 외부 통신은 직접 호출하지 않고, Repository를 통해 간접적으로 수행합니다.

---

### 3. Data Layer

- **외부 데이터 통신 및 가공 계층**입니다.
- **Repository Implementation**: Domain Layer의 Repository 인터페이스를 구현합니다.
- **DataSource**: 외부 통신을 수행합니다 (Remote/Local).
- **DTO**: 데이터 전송 객체
- **Mapper**: DTO ↔ Entity 변환을 수행합니다.

---

# 🔥 데이터 흐름 (Provider 패턴)

```
UI Event → ViewModel → UseCase → Repository → DataSource
         ↓
   notifyListeners() → Consumer 리빌드
```

- 흐름은 항상 단방향입니다.
- 상위 레이어가 하위 레이어에만 의존합니다.
- 하위 레이어는 상위 레이어를 참조하지 않습니다.

---

# 🧠 상태 및 결과 관리 규칙

- **DataSource**는 네트워크 호출 결과를 반환합니다.
- **RepositoryImpl**은 DataSource를 호출하고 결과를 변환합니다.
- **RepositoryImpl**은 결과를 **Result<T>** 형태로 감싸서 반환합니다.
- **UseCase**는 Repository로부터 받은 Result<T>를 그대로 반환합니다.
- **ViewModel**은 UseCase로부터 받은 Result<T>를 처리하여 State를 업데이트하고 notifyListeners()를 호출합니다.

✅ **Result<T> 패턴은 Repository에서 생성, ViewModel에서 처리**

> 이 책임 분리를 통해 통신/실패 로직과 UI 상태 관리 로직을 명확히 구분할 수 있습니다.

---

# 🗂️ 폴더 구조 설계 (보완 설명)

| 폴더 | 역할 |
|:---|:---|
| data/datasources | 외부 통신 전용 (Firebase, REST API 등) |
| data/models | 서버와 통신하는 순수 데이터 객체 (DTO) |
| data/mappers | DTO ↔ Domain Entity 변환 책임 |
| data/repositories | Repository 인터페이스의 구현체 |
| domain/entities | 도메인 순수 엔티티 (비즈니스 단위 객체) |
| domain/repositories | Repository 인터페이스 (UseCase가 의존) |
| domain/usecases | 비즈니스 로직 실행 책임 |
| presentation/states | freezed 기반 상태 객체 |
| presentation/viewmodels | ChangeNotifier 기반 ViewModel |
| presentation/screens | ChangeNotifierProvider 설정 + UI |
| presentation/widgets | 재사용 가능한 UI 컴포넌트 |

✅ Repository 인터페이스는 domain에,  
✅ Repository 구현체는 data에 둡니다.  
✅ UseCase는 항상 Repository 인터페이스만 의존합니다.

---

# 🛠️ 레이어별 책임 요약

| 레이어 | 주요 책임 | 주의사항 |
|:---|:---|:---|
| Presentation (Screen/ViewModel) | 상태 관리, UI 이벤트 처리 | 직접 비즈니스 로직이나 외부 통신 호출 금지 |
| ViewModel | State 관리, UseCase 호출, notifyListeners | UseCase 호출 외에는 비즈니스 로직 직접 처리 금지 |
| UseCase | 비즈니스 규칙 실행 | 직접 외부 통신(DataSource) 호출 금지 |
| Repository (Interface) | 외부 데이터 접근 추상화 | 직접 DataSource 호출 안 함 |
| RepositoryImpl (Implementation) | 외부 데이터 가공 및 제공 | Result<T>로 감싸서 반환 |
| DataSource | 외부 통신 수행 | 외부 데이터 접근만 담당 |

---

# 🧩 예시 흐름 (구체적)

1. 사용자가 버튼 클릭 → UI에서 `context.read<ViewModel>().method()` 호출
2. ViewModel이 해당 Action에 맞는 UseCase 호출
3. UseCase가 Repository(Interface)를 호출
4. RepositoryImpl이 DataSource를 통해 외부 통신
5. 통신 결과(Result<T>)가 RepositoryImpl → UseCase → ViewModel로 전달
6. ViewModel이 Result<T>를 처리하여 State 업데이트 후 notifyListeners() 호출
7. Consumer가 상태 변경을 감지하여 UI 재렌더링

---

# ✅ 문서 요약

- 레이어는 Presentation → Domain → Data 순으로 구성합니다.
- 항상 단방향 흐름을 유지합니다.
- 비즈니스 로직은 UseCase에만 존재합니다.
- 외부 통신 결과는 RepositoryImpl에서 Result<T>로 감싸서 반환합니다.
- 상태 관리는 ViewModel이 담당하며 Provider 패턴으로 의존성을 주입합니다.
- 폴더 구조는 책임에 따라 세분화하여 관리합니다.