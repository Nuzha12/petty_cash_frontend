import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/token_service.dart';
import '../../auth/screens/login_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int? selectedCategoryId;
  List categories = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final res = await ApiService.get("/categories/");
      setState(() {
        categories = res;
        selectedCategoryId = categories.isNotEmpty ? categories[0]["category_id"] : null;
      });
    } catch (e) {}
  }

  void addExpense() async {
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select category")),
      );
      return;
    }

    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter amount")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.post(
        "/expenses/",
        {
          "amount": double.parse(amountController.text),
          "description": descriptionController.text,
          "category_id": selectedCategoryId,
          "expense_date": DateTime.now().toIso8601String().split("T")[0],
        },
      );

      Navigator.pop(context, true);

    } catch (e) {

      // ✅ TOKEN EXPIRED HANDLING (PASTE HERE)
      if (e.toString().contains("UNAUTHORIZED")) {
        final tokenService = TokenService();
        await tokenService.clear();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 10),

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
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 20),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: addExpense,
              child: const Text("Add Expense"),
            ),
          ],
        ),
      ),
    );
  }
}