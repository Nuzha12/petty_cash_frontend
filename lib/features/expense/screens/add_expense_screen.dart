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
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future loadCategories() async {
    final res = await ApiService.request("GET", "/categories");
    setState(() {
      categories = res;
      if (categories.isNotEmpty) {
        categoryId = categories[0]["category_id"];
      }
    });
  }

  void add() async {
    if (amountController.text.isEmpty || categoryId == null) return;

    setState(() => loading = true);

    await ExpenseService.addExpense({
      "amount": double.parse(amountController.text),
      "description": descriptionController.text,
      "category_id": categoryId,
      "expense_date": DateTime.now().toIso8601String().split("T")[0],
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(title: const Text("Add Expense")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            buildField("Amount", amountController),

            const SizedBox(height: 10),

            DropdownButtonFormField<int>(
              value: categoryId,
              decoration: fieldDecoration("Category"),
              items: categories.map<DropdownMenuItem<int>>((c) {
                return DropdownMenuItem(
                  value: c["category_id"],
                  child: Text(c["name"]),
                );
              }).toList(),
              onChanged: (v) => setState(() => categoryId = v),
            ),

            const SizedBox(height: 10),

            buildField("Description", descriptionController),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : add,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Expense"),
              ),
            ),

            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: fieldDecoration(label),
    );
  }

  InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}