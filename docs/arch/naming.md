# 네이밍 컨벤션

## 파일 네이밍

### 1. Dart 파일
- 소문자와 언더스코어 사용
- 기능을 명확히 표현
- 접미사로 역할 표시

```
✅ 올바른 예시:
- transaction_repository.dart
- auth_bloc.dart
- user_model.dart
- home_screen.dart
- custom_button.dart

❌ 잘못된 예시:
- TransactionRepository.dart
- authBloc.dart
- user.dart
- HomeScreen.dart
```

### 2. 테스트 파일
- 테스트 대상 파일명 + _test 접미사
- 테스트 종류별 접미사 사용

```
✅ 올바른 예시:
- transaction_repository_test.dart
- auth_bloc_test.dart
- user_model_test.dart
- home_screen_widget_test.dart

❌ 잘못된 예시:
- test_transaction_repository.dart
- transaction_repository.spec.dart
```

## 클래스 네이밍

### 1. 일반 클래스
- 파스칼 케이스 사용
- 명사로 시작
- 역할을 명확히 표현

```
✅ 올바른 예시:
- TransactionRepository
- AuthBloc
- UserModel
- HomeScreen
- CustomButton

❌ 잘못된 예시:
- transactionRepository
- auth_bloc
- user
- home_screen
```

### 2. 인터페이스/추상 클래스
- I 접두사 또는 Abstract 접두사 사용
- 구현체와 구분되도록 명명

```
✅ 올바른 예시:
- ITransactionRepository
- AbstractAuthBloc
- IUserService
- AbstractBaseModel

❌ 잘못된 예시:
- TransactionRepository
- AuthBloc
- UserService
- BaseModel
```

## 변수/함수 네이밍

### 1. 변수
- 카멜 케이스 사용
- 명사로 시작
- 의미를 명확히 표현

```
✅ 올바른 예시:
- transactionList
- userProfile
- isLoading
- currentIndex

❌ 잘못된 예시:
- transaction_list
- UserProfile
- is_loading
- index
```

### 2. 함수/메서드
- 카멜 케이스 사용
- 동사로 시작
- 동작을 명확히 표현

```
✅ 올바른 예시:
- getTransactions()
- updateUserProfile()
- calculateTotal()
- handleSubmit()

❌ 잘못된 예시:
- transactions()
- user_profile_update()
- total()
- submit()
```

### 3. 상수
- 스네이크 케이스 사용
- 대문자로 작성
- 의미를 명확히 표현

```
✅ 올바른 예시:
- MAX_RETRY_COUNT
- DEFAULT_TIMEOUT
- API_BASE_URL
- ERROR_MESSAGE

❌ 잘못된 예시:
- maxRetryCount
- defaultTimeout
- apiBaseUrl
- errorMessage
```

## 패키지/모듈 네이밍

### 1. 패키지
- 소문자 사용
- 하이픈으로 단어 구분
- 의미를 명확히 표현

```
✅ 올바른 예시:
- transaction-service
- auth-module
- user-management
- common-utils

❌ 잘못된 예시:
- TransactionService
- auth_module
- userManagement
- CommonUtils
```

### 2. 모듈
- 카멜 케이스 사용
- 의미를 명확히 표현
- 역할을 명시

```
✅ 올바른 예시:
- transactionModule
- authModule
- userModule
- commonModule

❌ 잘못된 예시:
- transaction_module
- AuthModule
- user
- common
```

## 네이밍 Best Practices

### 1. 일관성
- 프로젝트 전체에서 일관된 네이밍 사용
- 팀 내 네이밍 규칙 준수
- 기존 코드 스타일 유지

### 2. 명확성
- 의미를 명확히 전달
- 축약어 사용 지양
- 역할과 책임을 명확히 표현

### 3. 간결성
- 불필요한 접두사/접미사 제거
- 적절한 길이 유지
- 중복되는 단어 제거

### 4. 검색 용이성
- 검색하기 쉬운 이름 사용
- 일관된 접두사/접미사 사용
- 관련 코드 그룹화 용이

## 네이밍 체크리스트

### 1. 파일 네이밍
- [ ] 소문자와 언더스코어 사용
- [ ] 역할을 명확히 표현
- [ ] 테스트 파일 규칙 준수

### 2. 클래스 네이밍
- [ ] 파스칼 케이스 사용
- [ ] 역할을 명확히 표현
- [ ] 인터페이스/추상 클래스 구분

### 3. 변수/함수 네이밍
- [ ] 카멜 케이스 사용
- [ ] 의미를 명확히 표현
- [ ] 상수는 대문자 사용

### 4. 패키지/모듈 네이밍
- [ ] 일관된 케이스 사용
- [ ] 의미를 명확히 표현
- [ ] 역할을 명시
