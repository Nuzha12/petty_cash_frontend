import 'package:flutter/material.dart';
import 'package:petty_cash_fontend/features/expense/screens/add_expense_screen.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';

class AppRoutes {
  static const login = '/';
  static const dashboard = '/dashboard';
  static const addExpense = '/add-expense';

  static final routes = {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    addExpense: (context) => const AddExpenseScreen(),
  };
}