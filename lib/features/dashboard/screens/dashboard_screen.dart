import 'package:flutter/material.dart';
import 'package:petty_cash_fontend/core/services/api_service.dart';
import 'package:petty_cash_fontend/core/services/token_service.dart';
import 'package:petty_cash_fontend/features/auth/screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String token;

  const DashboardScreen({super.key, required this.token});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final now = DateTime.now();

      final res = await ApiService.get("/dashboard/?month=${now.month}&year=${now.year}");
      setState(() {
        data = res;
      });
    } catch (e) {
      if (e.toString().contains("UNAUTHORIZED")) {
        final tokenService = TokenService();
        await tokenService.clear();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }

    setState(() => isLoading = false);
  }

  Widget card(String title, dynamic value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF8E2DE2),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final tokenService = TokenService();
              await tokenService.clear();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          )
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          children: [

            const SizedBox(height: 20),

            Row(
              children: [
                card("Total", data?["total_expenses"] ?? 0),
                card("Today", data?["today"] ?? 0),
                card("Monthly", data?["monthly"] ?? 0),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: ListView.builder(
                  itemCount: data?["categories"]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = data!["categories"][index];

                    final name = item["category"]?.toString() ?? "Unknown";
                    final amount = item["total"]?.toString() ?? "0";

                    return ListTile(
                      title: Text(name),
                      trailing: Text(amount),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}