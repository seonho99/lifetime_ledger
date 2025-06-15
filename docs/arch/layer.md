# 레이어 구조

## Clean Architecture 레이어

### 1. Presentation Layer
- UI 관련 코드를 포함
- BLoC 패턴을 사용한 상태 관리
- 사용자 입력 처리
- 화면 구성 및 네비게이션

#### 주요 컴포넌트
- Pages/Screens
- Widgets
- BLoC (Business Logic Component)
- ViewModels

### 2. Domain Layer
- 비즈니스 로직을 포함
- 외부 의존성이 없는 순수한 Dart 코드
- 엔티티와 유스케이스 정의

#### 주요 컴포넌트
- Entities
- UseCases
- Repository Interfaces
- Value Objects

### 3. Data Layer
- 데이터 소스와 리포지토리 구현
- 외부 서비스와의 통신
- 데이터 변환 및 매핑

#### 주요 컴포넌트
- Repositories
- DataSources
- DTOs (Data Transfer Objects)
- Mappers

## 레이어 간 통신

### Presentation → Domain
- UseCase 호출
- Entity 사용
- Repository 인터페이스 참조

### Domain → Data
- Repository 구현체 사용
- DTO 변환
- 데이터 소스 접근

### Data → External
- API 호출
- 로컬 저장소 접근
- 외부 서비스 통신

## 의존성 규칙
1. 외부 레이어는 내부 레이어에 의존할 수 없음
2. 내부 레이어는 외부 레이어의 구현 세부사항을 알 수 없음
3. 의존성은 항상 안쪽을 향함

## 데이터 흐름
1. UI 이벤트 발생
2. BLoC에서 이벤트 처리
3. UseCase 호출
4. Repository를 통한 데이터 접근
5. 데이터 소스에서 데이터 조회
6. DTO → Entity 변환
7. UI 상태 업데이트

## 에러 처리
- 각 레이어에서 적절한 에러 처리
- 도메인 레이어에서 커스텀 예외 정의
- 프레젠테이션 레이어에서 사용자 친화적 에러 표시
