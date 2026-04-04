import '../features/auth/screens/login_screen.dart';
import '../features/expense/screens/add_expense_screen.dart';
import '../features/reports/screens/report_screen.dart';

class AppRoutes {
  static const login = '/';
  static const dashboard = '/dashboard';
  static const addExpense = '/add-expense';
  static const viewReports = '/reports';


  static final routes = {
    login: (context) => const LoginScreen(),
    addExpense: (context) => const AddExpenseScreen(),
    viewReports: (context) => const ReportScreen(),
  };
}