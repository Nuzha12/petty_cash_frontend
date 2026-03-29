import 'package:flutter/material.dart';
import 'package:petty_cash_fontend/core/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  Map data = {};
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final token = ModalRoute.of(context)!.settings.arguments as String;

    loadData(token);
  }

  void loadData(String token) async {
    try {
      final res = await ApiService.get(
        "/dashboard?month=3&year=2026",
        token,
      );

      setState(() {
        data = res;
        isLoading = false;
      });
    }
    catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"),),
      body: Padding(padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total: ${data["total_expenses"]}",
          style: const TextStyle(fontSize: 20),
          ),

          const SizedBox(height: 20,),

          ...data["categories"].map<Widget>((c){
            return Text("${c["category"]}: ${c["total"]}");
          }).toList()
        ],
       ),
      ),
    );
  }
}
