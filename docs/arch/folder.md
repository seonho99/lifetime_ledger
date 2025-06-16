# 폴더 구조

## 프로젝트 루트 구조
```
lib/
├── core/                # 핵심 유틸리티 및 상수
├── features/            # 기능별 모듈
├── shared/              # 공통 위젯 및 유틸리티
└── main.dart            # 앱 진입점
```

## Core 구조
```
core/
├── constants/           # 상수 정의
├── error/              # 에러 처리
├── network/            # 네트워크 관련
├── theme/              # 테마 설정
└── utils/              # 유틸리티 함수
```

## Feature 구조
```
features/
├── auth/               # 인증 관련 기능
├── budget/            # 예산 관리 기능
├── category/          # 카테고리 관리 기능
└── statistics/        # 통계 및 리포트 기능
```

## Feature 내부 구조
```
feature/
├── data/              # 데이터 레이어
│   ├── datasources/   # 데이터 소스
│   ├── models/        # DTO 모델
│   └── repositories/  # 리포지토리 구현
├── domain/            # 도메인 레이어
│   ├── entities/      # 도메인 엔티티
│   ├── repositories/  # 리포지토리 인터페이스
│   └── usecases/      # 유스케이스
└── presentation/      # 프레젠테이션 레이어
    ├── provider/      # 상태 관리
    ├── screen/        # 화면
    └── widgets/       # 위젯
```

## Shared 구조
```
shared/
├── widgets/           # 공통 위젯
├── services/          # 공통 서비스
└── extensions/        # 확장 메서드
```

## 테스트 구조
```
test/
├── unit/             # 단위 테스트
├── widget/           # 위젯 테스트
└── integration/      # 통합 테스트
```

## 리소스 구조
```
assets/
├── images/           # 이미지 리소스
├── icons/            # 아이콘 리소스
└── fonts/            # 폰트 리소스
```

## 설정 파일
```
├── pubspec.yaml      # 의존성 관리
├── analysis_options.yaml  # 린트 설정
└── firebase_options.dart  # Firebase 설정
```
