# 🗂️️ docs/ 폴더 구조

+ # Lifetime Ledger - 가계부 앱 문서
+ **아키텍처**: MVVM + Clean Architecture
+ **상태관리**: Provider 패턴
+ **프로젝트**: 개인 재정 관리 앱

```
docs/
├── overview/
│   ├── project.md                 # 프로젝트 소개 / 개요
│   ├── roadmap.md                 # MVVM + 확장 기능 정리
│
├── arch/
│   ├── folder.md                  # 기능 기반 폴더 구조
│   ├── layer.md                   # 레이어별 책임 및 흐름
│   ├── result.md                  # Result + UiState 패턴
│   ├── error.md                   # Failure/예외 처리 전략
│   ├── naming.md                  # 전반 네이밍 규칙
│   ├── route.md                   # 라우팅 설계 가이드
│
├── ui/
│   ├── component.md               # 공통 컴포넌트 작성 가이드
│   ├── screen.md                  # Screen 설계 가이드
│   ├── state.md                   # 상태 객체 작성 가이드
│   ├── viewmodel.md               # ViewModel 설계 가이드 
│   ├── view.md                    # View 설계 가이드 
│
├── logic/
│   ├── repository.md              # Repository 설계 및 메서드 규칙
│   ├── datasource.md              # DataSource 구조 및 규칙
│   ├── usecase.md                 # UseCase 설계 및 변환 흐름
│   ├── model.md                   # 도메인 모델 정의 가이드
│   ├── dto.md                     # DTO 설계 기준
│   ├── mapper.md                  # DTO ↔ Model 변환 기준
│   ├── firebase_model.md          # Firebase 모델 구조 정의

```

---

# 📚 주요 파일 설명

| 경로                    | 설명                                     |
|-----------------------|----------------------------------------|
| `overview/project.md` | 프로젝트 목적, 컨셉, 주요 흐름 요약                  |
| `overview/roadmap.md` | MVP 기능 정의 + 향후 확장 기능 목록화               |
| `arch/folder.md`      | 기능 단위 기반의 디렉토리 구조, 예시 포함               |
| `arch/layer.md`       | data → domain → presentation 흐름, 역할 구분 |
| `arch/result.md`      | Result 패턴 소개                           |
| `arch/error.md`       | 예외 → Failure 매핑 전략, 디버깅 유틸             |
| `arch/naming.md`      | 파일명, 클래스명, 접두어 규칙 총정리                  |
| `arch/route.md`       | 라우팅 구조, GoRouter 설정 및 네비게이션 방식        |
| `ui/screen.md`        | 화면별 ChangeNotifierProvider 설정 가이드        |
| `ui/state.md`         | 상태 객체 작성 및 freezed 사용법               |
| `ui/viewmodel.md`     | ViewModel 설계, Provider 기반 상태 관리         |
| `ui/view.md`          | View 설계, MVVM 패턴 적용 가이드               |
| `ui/component.md`     | 공통 위젯 구조, width/height 처리 원칙           |
| `logic/repository.md` | Repository interface/impl 규칙 및 메서드 접두사 |
| `logic/datasource.md` | DataSource 인터페이스/Mock/Impl 규칙, Mock 상태 관리 |
| `logic/usecase.md`    | UseCase의 역할, Result → ViewModel 흐름 처리     |
| `logic/model.md`      | Model(Entity) class 설계 원칙 및 생성 규칙      |
| `logic/dto.md`        | Dto 설계 원칙 및 생성 규칙                      |
| `logic/mapper.md`     | Mapper 설계 원칙 및 생성 규칙                   |
| `logic/firebase_model.md` | Firebase 컬렉션 구조 및 DTO 정의             |

---

# ✅ 문서 구조 설계 기준

+ - **한 파일 = 하나의 목적만** 다룸 (예: viewmodel 가이드는 viewmodel만)
+ - **폴더는 4개로 고정**: overview, arch, ui, logic,
+ - **Provider + MVVM + Clean Architecture** 구조에 맞춘 문서화
+ - **AI가 빠르게 맥락 파악** 가능하도록 구조화

---
