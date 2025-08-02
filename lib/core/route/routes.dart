abstract class Routes {
  // 인증 관련
  static const String signIn = '/sign_in';
  static const String signUp = '/sign_up';
  static const String changePassword = '/change_password';

  // 메인 앱 관련 (ShellRoute)
  static const String home = '/home';
  static const String history = '/history';
  static const String stats = '/stats';
  static const String settings = '/settings';

  // 수입/지출 관련
  static const String addIncome = '/add_income';
  static const String addExpense = '/add_expense';

  // 통계 관련
  static const String monthlyChart = '/monthly-chart';

  // 기타
  static const String splash = '/';
  
  // 레거시 (호환성)
  static const String main = '/home'; // main을 home으로 리다이렉트
}