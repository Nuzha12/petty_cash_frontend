import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../../../core/services/api_service.dart';
import 'edit_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    setState(() => loading = true);
    final res = await ExpenseService.getExpenses();
    setState(() {
      data = res ?? [];
      loading = false;
    });
  }

  Future approve(int id) async {
    final res = await ApiService.request("PATCH", "/expenses/$id/approve");
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense Approved"), backgroundColor: Colors.green),
      );
      load();
    }
  }

  double toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  Color getStatusColor(String status) {
    if (status == "approved") return Colors.green;
    if (status == "rejected") return Colors.red;
    return Colors.orange;
  }

  String getStatusText(String status) {
    if (status == "approved") return "Approved";
    if (status == "rejected") return "Rejected";
    return "Pending";
  }

  void deleteExpense(int id, String status) async {
    if (status != "pending") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only pending expenses can be deleted")),
      );
      return;
    }
    await ExpenseService.deleteExpense(id);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add');
          if (result == true) load();
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (_, i) {
            final e = data[i];
            final status = e["status"] ?? "pending";
            final isPending = status == "pending";

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.receipt, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e["category"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(e["description"] ?? ""),
                        Text(
                          getStatusText(status),
                          style: TextStyle(color: getStatusColor(status), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("LKR ${toDouble(e["amount"])}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          if (isPending)
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green, size: 22),
                              onPressed: () => approve(e["expense_id"]),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                            onPressed: isPending
                                ? () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: e)),
                              );
                              if (result == true) load();
                            }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => deleteExpense(e["expense_id"], status),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}