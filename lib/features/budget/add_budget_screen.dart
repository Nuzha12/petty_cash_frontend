import 'package:flutter/material.dart';
import 'package:petty_cash_fontend/core/services/api_service.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {

  final amountController = TextEditingController();
  int? selectedCategoryId;
  List categories = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final res = await ApiService.get("/categories/");
    setState(() {
      categories = res;
      selectedCategoryId = categories.isNotEmpty ? categories[0]["category_id"] : null;
    });
  }

  void saveBudget() async {
    if (selectedCategoryId == null) return;

    setState(() => isLoading = true);

    try {
      await ApiService.post("/budgets/", {
        "category_id": selectedCategoryId,
        "amount": double.parse(amountController.text),
        "month": DateTime.now().month,
        "year": DateTime.now().year,
      });

      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Add Budget")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            DropdownButtonFormField<int>(
              value: selectedCategoryId,
              items: categories.map<DropdownMenuItem<int>>((c) {
                return DropdownMenuItem(
                  value: c["category_id"],
                  child: Text(c["name"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedCategoryId = value);
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Budget Amount"),
            ),

            const SizedBox(height: 20),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: saveBudget,
              child: const Text("Save Budget"),
            ),
          ],
        ),
      ),
    );
  }
}