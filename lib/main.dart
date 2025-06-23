import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Auth DataSource & Repository
import 'data/datasource/auth_datasource_impl.dart';
import 'data/repository_impl/auth_repository_impl.dart';
import 'domain/repository/auth_repository.dart';

// Auth UseCases
import 'domain/usecase/signin_usecase.dart';
import 'domain/usecase/signup_usecase.dart';
import 'domain/usecase/signout_usecase.dart';
import 'domain/usecase/send_password_reset_email_usecase.dart';
import 'domain/usecase/change_password_usecase.dart';
import 'domain/usecase/update_profile_usecase.dart';
import 'domain/usecase/send_email_verification_usecase.dart';
import 'domain/usecase/delete_account_usecase.dart';

// History DataSource & Repository
import 'data/datasource/history_datasource_impl.dart';
import 'data/repository_impl/history_repository_impl.dart';
import 'domain/repository/history_repository.dart';

// History UseCases
import 'domain/usecase/get_histories_usecase.dart';
import 'domain/usecase/add_history_usecase.dart';
import 'domain/usecase/update_history_usecase.dart';
import 'domain/usecase/delete_history_usecase.dart';
import 'domain/usecase/get_histories_by_month_usecase.dart';

// UI
import 'ui/auth/auth_viewmodel.dart';
import 'ui/history/history_screen.dart';
import 'ui/auth/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 한국어 로케일 초기화
  await initializeDateFormatting('ko_KR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ========================================
        // Core Services
        // ========================================
        Provider<FirebaseAuth>(
          create: (context) => FirebaseAuth.instance,
        ),
        Provider<FirebaseFirestore>(
          create: (context) => FirebaseFirestore.instance,
        ),

        // ========================================
        // Auth Layer
        // ========================================

        // Auth DataSource
        Provider(
          create: (context) => AuthFirebaseDataSourceImpl(
            firebaseAuth: context.read<FirebaseAuth>(),
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),

        // Auth Repository
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            dataSource: context.read<AuthFirebaseDataSourceImpl>(),
          ),
        ),

        // Auth UseCases
        Provider(
          create: (context) => SignInUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider(
          create: (context) => SignUpUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider(
          create: (context) => SignOutUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider(
          create: (context) => SendPasswordResetEmailUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider(
          create: (context) => ChangePasswordUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider(
          create: (context) => UpdateProfileUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider(
          create: (context) => SendEmailVerificationUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider(
          create: (context) => DeleteAccountUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),

        // Auth ViewModel
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            signInUseCase: context.read<SignInUseCase>(),
            signUpUseCase: context.read<SignUpUseCase>(),
            signOutUseCase: context.read<SignOutUseCase>(),
            sendPasswordResetEmailUseCase: context.read<SendPasswordResetEmailUseCase>(),
            changePasswordUseCase: context.read<ChangePasswordUseCase>(),
            updateProfileUseCase: context.read<UpdateProfileUseCase>(),
            sendEmailVerificationUseCase: context.read<SendEmailVerificationUseCase>(),
            deleteAccountUseCase: context.read<DeleteAccountUseCase>(),
          ),
        ),

        // ========================================
        // History Layer (기존)
        // ========================================

        // History DataSource
        Provider(
          create: (context) => HistoryFirebaseDataSourceImpl(
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),

        // History Repository
        Provider<HistoryRepository>(
          create: (context) => HistoryRepositoryImpl(
            dataSource: context.read<HistoryFirebaseDataSourceImpl>(),
          ),
        ),

        // History UseCases
        Provider(
          create: (context) => GetHistoriesUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => AddHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => UpdateHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => DeleteHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => GetHistoriesByMonthUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Lifetime Ledger',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        locale: const Locale('ko', 'KR'),
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ko', 'KR'),
        ],
        home: const AuthWrapper(), // 인증 상태에 따른 화면 분기
      ),
    );
  }
}

/// 인증 상태에 따라 화면을 분기하는 Wrapper
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Firebase Auth의 실시간 상태 변화를 스트림으로 감지
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // 연결 상태 확인 중
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            // 로그인 상태에 따른 화면 분기
            if (snapshot.hasData && snapshot.data != null) {
              // 로그인됨: HistoryScreen으로 이동
              return const HistoryScreen();
            } else {
              // 로그인 안됨: AuthScreen으로 이동
              return const AuthScreen();
            }
          },
        );
      },
    );
  }
}

/// 스플래시 화면 (Firebase 연결 대기 중)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Lifetime Ledger',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '나만의 가계부',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            // 로딩 인디케이터
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}