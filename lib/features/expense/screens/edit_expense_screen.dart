import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Map expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {

  late TextEditingController amountController;
  late TextEditingController descriptionController;

  int? categoryId;
  List categories = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    amountController =
        TextEditingController(text: widget.expense["amount"].toString());

    descriptionController =
        TextEditingController(text: widget.expense["description"] ?? "");

    categoryId = widget.expense["category_id"];

    loadCategories();
  }

  Future loadCategories() async {
    final res = await ApiService.request("GET", "/categories");
    setState(() => categories = res is List ? res : []);
  }

  void update() async {
    if (amountController.text.isEmpty || categoryId == null) return;

    setState(() => loading = true);

    try {
      await ExpenseService.updateExpense(
        widget.expense["expense_id"],
        {
          "amount": double.parse(amountController.text),
          "description": descriptionController.text,
          "category_id": categoryId,
        },
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: amountController),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: categoryId,
              items: categories.map<DropdownMenuItem<int>>((c) {
                return DropdownMenuItem(
                  value: c["category_id"],
                  child: Text(c["name"]),
                );
              }).toList(),
              onChanged: (v) => setState(() => categoryId = v),
            ),
            const SizedBox(height: 10),
            TextField(controller: descriptionController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : update,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Update"),
            )
          ],
        ),
      ),
    );
  }
}