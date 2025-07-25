import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Core Router
import 'core/route/router.dart';

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
        Provider<AuthFirebaseDataSourceImpl>(
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
        Provider<SignInUseCase>(
          create: (context) => SignInUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider<SignUpUseCase>(
          create: (context) => SignUpUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider<SignOutUseCase>(
          create: (context) => SignOutUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider<SendPasswordResetEmailUseCase>(
          create: (context) => SendPasswordResetEmailUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider<ChangePasswordUseCase>(
          create: (context) => ChangePasswordUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider<UpdateProfileUseCase>(
          create: (context) => UpdateProfileUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider<SendEmailVerificationUseCase>(
          create: (context) => SendEmailVerificationUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider<DeleteAccountUseCase>(
          create: (context) => DeleteAccountUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),

        // ========================================
        // History Layer
        // ========================================

        // History DataSource
        Provider<HistoryFirebaseDataSourceImpl>(
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
        Provider<GetHistoriesUseCase>(
          create: (context) => GetHistoriesUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider<AddHistoryUseCase>(
          create: (context) => AddHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider<UpdateHistoryUseCase>(
          create: (context) => UpdateHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider<DeleteHistoryUseCase>(
          create: (context) => DeleteHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider<GetHistoriesByMonthUseCase>(
          create: (context) => GetHistoriesByMonthUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Lifetime Ledger',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: 'Noto Sans',
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}