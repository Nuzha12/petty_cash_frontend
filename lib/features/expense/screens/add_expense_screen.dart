import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  int? categoryId;
  List categories = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future loadCategories() async {
    final res = await ApiService.get("/categories/");
    setState(() => categories = res);
  }

  void addExpense() async {
    setState(() => isLoading = true);

    try {
      await ExpenseService.addExpense({
        "amount": double.parse(amountController.text),
        "description": descriptionController.text,
        "category_id": categoryId,
        "expense_date": DateTime.now().toIso8601String().split("T")[0],
      });

      Navigator.pop(context, true);

    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(controller: amountController),

            DropdownButtonFormField<int>(
              items: categories.map<DropdownMenuItem<int>>((c) {
                return DropdownMenuItem(
                  value: c["category_id"],
                  child: Text(c["name"]),
                );
              }).toList(),
              onChanged: (v) => categoryId = v,
            ),

            TextField(controller: descriptionController),

            ElevatedButton(
              onPressed: isLoading ? null : addExpense,
              child: const Text("Add"),
            )
          ],
        ),
      ),
    );
  }
}