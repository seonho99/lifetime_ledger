# 🔥 Firestore 데이터베이스 구조 설계 (NoSQL 최적화)

## ✅ NoSQL 특성을 고려한 컬렉션 구조

```
lifetime-ledger (Project)
├── users/{userId}                    # 사용자 프로필만
├── transactions/{transactionId}      # 모든 거래 (userId로 필터링)
├── categories/{categoryId}           # 카테고리 마스터
├── monthly_stats/{userId_YYYY_MM}    # 월별 집계 (비정규화)
└── user_categories/{userId}          # 사용자별 카테고리 설정
```

## 🎯 NoSQL 설계 원칙 적용

## 🎯 NoSQL 설계 원칙 적용

### 1. **비정규화 우선**: 조인 없이 단일 쿼리로 해결
### 2. **읽기 최적화**: 쓰기 시 약간의 중복을 허용하여 읽기 성능 극대화
### 3. **플랫 구조**: 깊은 중첩 대신 플랫한 컬렉션 구조
### 4. **쿼리 패턴 기반**: 실제 사용할 쿼리에 맞춰 데이터 구조 설계

## 📊 컬렉션별 상세 구조

### 1. Users (`users/{userId}`) - 프로필만
```typescript
{
  id: string,
  email: string,
  displayName: string,
  photoURL?: string,
  settings: {
    currency: "KRW",
    defaultCategories: string[], // 즐겨찾는 카테고리 ID 배열
    monthlyBudget: number
  },
  createdAt: Timestamp,
  lastLoginAt: Timestamp
}
```

### 2. Transactions (`transactions/{transactionId}`) - 핵심 컬렉션
```typescript
{
  id: string,
  userId: string, // 사용자 필터링용
  
  // 거래 기본 정보
  title: string,
  amount: number,
  type: "income" | "expense",
  date: Timestamp,
  description?: string,
  
  // 카테고리 정보 (비정규화)
  categoryId: string,
  categoryName: string,    // 중복 저장 (읽기 최적화)
  categoryIcon: string,    // 중복 저장
  categoryColor: string,   // 중복 저장
  
  // 시간 기반 인덱싱용 (쿼리 최적화)
  year: number,           // 2024
  month: number,          // 12  
  yearMonth: string,      // "2024-12"
  day: number,            // 19
  
  // 메타데이터
  createdAt: Timestamp,
  updatedAt: Timestamp,
  
  // 확장 필드
  tags?: string[],
  location?: string,
  receiptUrl?: string
}
```

### 3. Categories (`categories/{categoryId}`) - 마스터 데이터
```typescript
{
  id: string,
  name: string,
  type: "income" | "expense",
  icon: string,
  color: string,
  isDefault: boolean,    // 기본 제공 여부
  isActive: boolean,
  order: number,         // 정렬 순서
  createdAt: Timestamp
}
```

### 4. Monthly Stats (`monthly_stats/{userId_YYYY_MM}`) - 집계 데이터
```typescript
// 문서 ID: "user123_2024_12"
{
  userId: string,
  year: number,
  month: number,
  yearMonth: string,      // "2024-12"
  
  // 전체 통계
  totalIncome: number,
  totalExpense: number,
  balance: number,
  transactionCount: number,
  
  // 카테고리별 통계 (비정규화)
  categoryStats: {
    "food": {
      name: "식비",
      amount: 500000,
      count: 25,
      percentage: 35.5
    },
    "transport": {
      name: "교통비", 
      amount: 200000,
      count: 15,
      percentage: 14.2
    }
  },
  
  // 일별 통계
  dailyStats: {
    "1": 50000,
    "2": 25000,
    // ...
  },
  
  lastUpdated: Timestamp
}
```

### 5. User Categories (`user_categories/{userId}`) - 사용자별 카테고리 설정
```typescript
{
  userId: string,
  favoriteCategories: string[],      // 즐겨찾기 카테고리 ID
  hiddenCategories: string[],        // 숨긴 카테고리 ID
  customCategories: {                // 사용자 생성 카테고리
    "custom_1": {
      name: "용돈",
      type: "income", 
      icon: "💰",
      color: "#FF5733"
    }
  },
  categoryOrder: string[],           // 사용자별 카테고리 정렬 순서
  updatedAt: Timestamp
}
```

## 🔍 NoSQL 최적화 쿼리 패턴

### 1. **거래 내역 조회** (가장 자주 사용)
```dart
// 특정 사용자의 최근 거래 (페이지네이션)
Query query = _firestore
    .collection('transactions')
    .where('userId', isEqualTo: userId)
    .orderBy('date', descending: true)
    .limit(20);

// 특정 월 거래 내역
Query monthlyQuery = _firestore
    .collection('transactions')
    .where('userId', isEqualTo: userId)
    .where('yearMonth', isEqualTo: '2024-12')
    .orderBy('date', descending: true);

// 카테고리별 거래
Query categoryQuery = _firestore
    .collection('transactions') 
    .where('userId', isEqualTo: userId)
    .where('categoryId', isEqualTo: 'food')
    .orderBy('date', descending: true);
```

### 2. **월별 통계 조회** (빠른 집계)
```dart
// 특정 월 통계 - 단일 문서 읽기로 모든 통계 획득
DocumentSnapshot monthlyStats = await _firestore
    .doc('monthly_stats/${userId}_2024_12')
    .get();

// 연간 통계 - 12개 문서만 읽기
QuerySnapshot yearlyStats = await _firestore
    .collection('monthly_stats')
    .where('userId', isEqualTo: userId)
    .where('year', isEqualTo: 2024)
    .get();
```

### 3. **실시간 업데이트 로직**
```dart
// 거래 추가 시 월별 통계 자동 업데이트 (Cloud Function)
exports.updateMonthlyStats = functions.firestore
    .document('transactions/{transactionId}')
    .onWrite(async (change, context) => {
        const transaction = change.after.data();
        const monthlyStatsId = `${transaction.userId}_${transaction.yearMonth}`;
        
        // 원자적 업데이트
        await admin.firestore().doc(`monthly_stats/${monthlyStatsId}`).update({
            totalExpense: FieldValue.increment(transaction.amount),
            transactionCount: FieldValue.increment(1),
            [`categoryStats.${transaction.categoryId}.amount`]: FieldValue.increment(transaction.amount),
            [`categoryStats.${transaction.categoryId}.count`]: FieldValue.increment(1),
            lastUpdated: FieldValue.serverTimestamp()
        });
    });
```

## 🚀 인덱스 설계 (최소한의 복합 인덱스)

### Transactions 컬렉션
```
1. (userId, date desc) - 사용자별 최근 거래
2. (userId, yearMonth, date desc) - 월별 거래  
3. (userId, categoryId, date desc) - 카테고리별 거래
4. (userId, type, date desc) - 수입/지출별 거래
```

### Monthly Stats 컬렉션
```
1. (userId, year) - 연간 통계
```

## 💡 NoSQL 장점 활용

### 1. **읽기 성능 극대화**
- 거래 내역에 카테고리 정보 비정규화 → 조인 없이 단일 쿼리
- 월별 통계 사전 계산 → 복잡한 집계 없이 단일 문서 읽기

### 2. **확장성**
- 플랫 구조로 무제한 확장 가능
- 사용자별 데이터 샤딩 가능

### 3. **실시간 성능**
- Cloud Functions로 비동기 집계 업데이트
- 읽기와 쓰기 분리

## ⚠️ 트레이드오프 관리

### 데이터 일관성
```dart
// Transaction 추가 시 관련 데이터 일괄 업데이트
Future<void> addTransaction(Transaction transaction) async {
  final batch = _firestore.batch();
  
  // 1. 거래 추가
  batch.set(_firestore.collection('transactions').doc(), {
    ...transaction.toFirestore(),
    'categoryName': await getCategoryName(transaction.categoryId), // 비정규화
  });
  
  // 2. 월별 통계 업데이트는 Cloud Function에서 비동기 처리
  
  await batch.commit();
}
```

### 스토리지 중복
```dart
// 카테고리 변경 시 모든 관련 거래 업데이트 (배치 처리)
Future<void> updateCategoryName(String categoryId, String newName) async {
  // 1. 카테고리 마스터 업데이트
  await _firestore.doc('categories/$categoryId').update({'name': newName});
  
  // 2. 관련 거래들 배치 업데이트 (백그라운드)
  final transactions = await _firestore
      .collection('transactions')
      .where('categoryId', isEqualTo: categoryId)
      .get();
      
  final batch = _firestore.batch();
  for (final doc in transactions.docs) {
    batch.update(doc.reference, {'categoryName': newName});
  }
  await batch.commit();
}
```

## 📱 보안 규칙 (단순화)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 프로필
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // 거래 내역 (userId 필터링)
    match /transactions/{transactionId} {
      allow read, write: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
    
    // 카테고리 (모든 인증 사용자 읽기 가능)
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if false; // 관리자만 수정 가능
    }
    
    // 월별 통계 (사용자별)
    match /monthly_stats/{statsId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow write: if false; // Cloud Function만 업데이트
    }
    
    // 사용자별 카테고리 설정
    match /user_categories/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

## 🎯 이 구조의 NoSQL 최적화 포인트

### ✅ **JOIN 제거**
- 거래 내역에 카테고리 정보 비정규화
- 단일 쿼리로 모든 필요 정보 획득

### ✅ **집계 쿼리 제거**
- 월별 통계 사전 계산 저장
- 복잡한 SUM, GROUP BY 대신 단일 문서 읽기

### ✅ **플랫 구조**
- 서브컬렉션 최소화
- 모든 거래를 단일 컬렉션에 저장

### ✅ **인덱스 최적화**
- 실제 쿼리 패턴에 맞는 최소한의 복합 인덱스
- 불필요한 인덱스 제거

### ✅ **확장성**
- 사용자별 데이터 자연스러운 샤딩
- 컬렉션별 독립적 확장 가능

## 🔄 데이터 플로우 예시

### 거래 추가 플로우
```
1. Frontend → 거래 추가 요청
2. Firestore → transactions 컬렉션에 문서 생성 (카테고리 정보 비정규화 포함)
3. Cloud Function → monthly_stats 자동 업데이트 (비동기)
4. Frontend → 실시간 업데이트 받음
```

### 월별 내역 조회 플로우
```
1. Frontend → 특정 월 거래 요청
2. Firestore → transactions 컬렉션 단일 쿼리 (yearMonth 필터)
3. Frontend → 카테고리 정보 포함된 완전한 데이터 수신
```
