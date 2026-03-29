import 'package:flutter/material.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';

class AppRoutes {
  static const login = '/';
  static const dashboard = '/dashboard';

  static final routes = {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
  };
}