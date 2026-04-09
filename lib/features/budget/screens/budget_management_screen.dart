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
    final res = await ExpenseService.getBudgets();
    setState(() {
      budgets = res;
      loading = false;
    });
  }

  void open() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddBudgetForm(),
    ).then((v) {
      if (v == true) load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Budget")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (_, i) {
          final b = budgets[i];
          return ListTile(
            title: Text(b["category_name"]),
            subtitle: Text("${b["month"]}/${b["year"]}"),
            trailing: Text(fmt.format(b["amount"])),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: open,
        child: const Icon(Icons.add),
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

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    final res = await ApiService.request("GET", "/categories");
    setState(() {
      categories = res;
      if (categories.isNotEmpty) {
        categoryId = categories[0]["category_id"];
      }
    });
  }

  void save() async {
    if (controller.text.isEmpty || categoryId == null) return;

    final now = DateTime.now();

    await ExpenseService.setBudget({
      "category_id": categoryId,
      "amount": double.parse(controller.text),
      "month": now.month,
      "year": now.year,
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          TextField(controller: controller),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: save,
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}