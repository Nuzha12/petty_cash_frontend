import 'package:flutter/material.dart';
import 'package:petty_cash_fontend/core/services/api_service.dart';

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {

  List budgets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    final res = await ApiService.get("/budgets/");
    setState(() {
      budgets = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Budgets")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final b = budgets[index];

          return ListTile(
            title: Text(b["category_name"]),
            subtitle: Text("Budget: ${b["amount"]}"),
            trailing: Text("Used: ${b["used"] ?? 0}"),
          );
        },
      ),
    );
  }
}