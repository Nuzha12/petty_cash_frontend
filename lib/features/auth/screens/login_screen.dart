import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petty_cash_fontend/core/services/api_service.dart';
import 'package:petty_cash_fontend/core/services/token_service.dart';
import 'package:petty_cash_fontend/features/dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = false;
  bool isLoading = false;
  bool obscurePassword = true;

  final tokenService = TokenService();

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiService.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      final token = data["access_token"];

      await tokenService.saveToken(token, rememberMe);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(token: token),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login failed")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.person, size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: usernameController,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) =>
                            value!.isEmpty ? "Enter username" : null,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person, color: Colors.white),
                              hintText: "Username",
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) =>
                            value!.length < 6 ? "Min 6 characters" : null,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock, color: Colors.white),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                              hintText: "Password",
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value!;
                                      });
                                    },
                                    activeColor: Colors.white,
                                  ),
                                  const Text(
                                    "Remember me",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : const Text("LOGIN"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}