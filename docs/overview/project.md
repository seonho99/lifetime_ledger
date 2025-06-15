# Lifetime Ledger - 개인 재정 관리 앱

## 프로젝트 개요
Lifetime Ledger는 사용자의 일상적인 재정 관리를 돕는 모바일 애플리케이션입니다. 
사용자는 수입과 지출을 쉽게 기록하고, 예산을 관리하며, 재정 상태를 시각적으로 파악할 수 있습니다.

## 주요 기능
1. 거래 관리
   - 수입/지출 기록 및 수정
   - 카테고리 기반 분류
   - 메모 및 영수증 첨부
   - 반복 거래 설정

2. 예산 관리
   - 월별/카테고리별 예산 설정
   - 예산 달성도 실시간 추적
   - 예산 초과 알림

3. 통계 및 리포트
   - 월별/연별 수입/지출 분석
   - 카테고리별 지출 패턴
   - 커스텀 기간 리포트
   - 시각적 차트 및 그래프

4. 사용자 관리
   - 이메일/구글 로그인
   - 프로필 관리
   - 데이터 백업/복원

## 기술 스택
- Frontend: Flutter
- Backend: Firebase
  - Authentication: 사용자 인증
  - Cloud Firestore: 데이터 저장
  - Cloud Storage: 파일 저장
  - Cloud Functions: 서버리스 로직

## 아키텍처
- Clean Architecture
  - Presentation Layer (UI)
  - Domain Layer (Business Logic)
  - Data Layer (Repository)
- BLoC 패턴 (상태 관리)
- Repository 패턴
- UseCase 패턴

## 개발 환경
- Flutter SDK: 3.x
- Dart SDK: 3.x
- Firebase SDK: Latest
- IDE: VS Code / Android Studio

## 타겟 플랫폼
- iOS 13.0+
- Android 8.0+
