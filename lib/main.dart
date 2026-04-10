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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? token;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  Future<void> checkToken() async {
    final savedToken = await TokenService().getToken();
    if (!mounted) return;
    setState(() {
      token = savedToken;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (token != null && token!.isNotEmpty) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}