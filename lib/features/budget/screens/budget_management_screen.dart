import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../expense/services/expense_service.dart';
import '../../../core/services/api_service.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  List budgets = [];
  bool loading = true;
  final fmt = NumberFormat.currency(locale: 'en_LK', symbol: 'LKR ');

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    try {
      final res = await ExpenseService.getBudgets();
      setState(() {
        budgets = res ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void open() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const AddBudgetForm(),
      ),
    ).then((v) {
      if (v == true) load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Budget Management")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : budgets.isEmpty
          ? const Center(child: Text("No budgets set for this month"))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: budgets.length,
        itemBuilder: (_, i) {
          final b = budgets[i];
          // Safe parsing to prevent 'isNegative' or type errors
          final double amount = double.tryParse(b["amount"].toString()) ?? 0.0;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.pie_chart, color: Colors.blue),
              ),
              title: Text(
                b["category_name"] ?? "Unknown Category",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Period: ${b["month"]}/${b["year"]}"),
              trailing: Text(
                fmt.format(amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: open,
        backgroundColor: const Color(0xFF4A00E0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddBudgetForm extends StatefulWidget {
  const AddBudgetForm({super.key});

  @override
  State<AddBudgetForm> createState() => _AddBudgetFormState();
}

class _AddBudgetFormState extends State<AddBudgetForm> {
  final controller = TextEditingController();
  int? categoryId;
  List categories = [];
  bool loadingCategories = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future loadCategories() async {
    try {
      final res = await ApiService.request("GET", "/categories");
      setState(() {
        categories = res ?? [];
        if (categories.isNotEmpty) {
          categoryId = categories[0]["category_id"];
        }
        loadingCategories = false;
      });
    } catch (e) {
      setState(() => loadingCategories = false);
    }
  }

  void save() async {
    if (controller.text.isEmpty || categoryId == null) return;

    setState(() => saving = true);
    final now = DateTime.now();
    try {
      await ExpenseService.setBudget({
        "category_id": categoryId,
        "amount": double.parse(controller.text),
        "month": now.month,
        "year": now.year,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Set Monthly Budget",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          loadingCategories
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<int>(
            value: categoryId,
            decoration: const InputDecoration(
              labelText: "Select Category",
              border: OutlineInputBorder(),
            ),
            items: categories.map<DropdownMenuItem<int>>((c) {
              return DropdownMenuItem(
                value: c["category_id"],
                child: Text(c["name"] ?? "Unknown"),
              );
            }).toList(),
            onChanged: (v) => setState(() => categoryId = v),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Budget Amount (LKR)",
              border: OutlineInputBorder(),
              hintText: "0.00",
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: saving ? null : save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A00E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "SAVE BUDGET",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}