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
  bool isLoading = false;

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
    final res = await ApiService.get("/categories/");
    setState(() => categories = res);
  }

  void updateExpense() async {
    if (amountController.text.isEmpty || categoryId == null) return;

    setState(() => isLoading = true);

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
      final msg = e.toString();

      if (msg.contains("budget exceeded")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Budget exceeded for this category")),
        );
      } else if (msg.contains("please set a budget")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Set a budget first")),
        );
      } else if (msg.contains("Only pending")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Only pending expenses can be edited")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Expense")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

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
              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateExpense,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Update Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}