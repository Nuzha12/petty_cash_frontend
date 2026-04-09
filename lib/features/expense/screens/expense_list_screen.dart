import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import 'edit_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {

  List data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    final res = await ExpenseService.getExpenses();
    setState(() => data = res);
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

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (_, i) {

          final e = data[i];
          final status = e["status"] ?? "pending";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5)
              ],
            ),
            child: Row(
              children: [

                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.receipt, color: Colors.white),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        e["category"] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Text(e["description"] ?? ""),

                      Text(
                        getStatusText(status),
                        style: TextStyle(
                          color: getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [

                    Text("LKR ${toDouble(e["amount"])}"),

                    Row(
                      children: [

                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: status == "pending"
                              ? () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditExpenseScreen(expense: e),
                              ),
                            );
                            if (result == true) load();
                          }
                              : null,
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
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
    );
  }
}