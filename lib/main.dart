import 'package:flutter/material.dart';
import 'core/services/token_service.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/expense/screens/add_expense_screen.dart';
import 'features/expense/screens/expense_list_screen.dart';
import 'features/reports/screens/report_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Petty Cash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      routes: {
        '/add': (context) => const AddExpenseScreen(),
        '/expenses': (context) => const ExpenseListScreen(),
        '/reports': (context) => const ReportScreen(),
      },

      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenService().getToken(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}