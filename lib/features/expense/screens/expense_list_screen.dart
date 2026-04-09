import 'package:flutter/material.dart';
import '../services/expense_service.dart';

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

  Color getStatusColor(String status) {
    if (status == "approved") return Colors.green;
    if (status == "rejected") return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (_, i) {
          final e = data[i];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                      Text(e['category'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(e['description'] ?? ""),
                      Text(
                        e['status'],
                        style: TextStyle(
                          color: getStatusColor(e['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),

                Column(
                  children: [
                    Text("LKR ${e['amount']}"),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          onPressed: e['status'] == "pending"
                              ? () async {
                            await ExpenseService.deleteExpense(e['expense_id']);
                            load();
                          }
                              : null,
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