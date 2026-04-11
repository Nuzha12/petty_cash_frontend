import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Map expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController amountController;
  late TextEditingController descController;
  int? categoryId;
  List categories = [];
  bool loading = false;
  late String status;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.expense['amount'].toString());
    descController = TextEditingController(text: widget.expense['description']);
    categoryId = widget.expense['category_id'];
    status = widget.expense['status'] ?? "pending";
    loadCategories();
  }

  Future loadCategories() async {
    final res = await ApiService.request("GET", "/categories");
    setState(() => categories = res ?? []);
  }

  void update() async {
    setState(() => loading = true);
    try {
      await ApiService.request("PATCH", "/expenses/${widget.expense['expense_id']}", data: {
        "amount": double.parse(amountController.text),
        "description": descController.text,
        "category_id": categoryId,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Expense")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: status == "approved" ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: status == "approved" ? Colors.green : Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(status == "approved" ? Icons.check_circle : Icons.pending,
                      color: status == "approved" ? Colors.green : Colors.orange),
                  const SizedBox(width: 10),
                  Text("Current Status: ${status.toUpperCase()}",
                      style: TextStyle(fontWeight: FontWeight.bold, color: status == "approved" ? Colors.green : Colors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount (LKR)", prefixIcon: Icon(Icons.money), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: categoryId,
              decoration: const InputDecoration(labelText: "Category", prefixIcon: Icon(Icons.category), border: OutlineInputBorder()),
              items: categories.map<DropdownMenuItem<int>>((c) {
                return DropdownMenuItem(value: c['category_id'], child: Text(c['name']));
              }).toList(),
              onChanged: (v) => setState(() => categoryId = v),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description", prefixIcon: Icon(Icons.description), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}