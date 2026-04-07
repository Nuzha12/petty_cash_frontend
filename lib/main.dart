import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'core/services/token_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final tokenService = TokenService();
    final token = await tokenService.getToken();

    if (token != null) {
      return DashboardScreen(token: token);
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Petty Cash App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}