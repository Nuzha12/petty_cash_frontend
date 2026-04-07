import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen>
    with SingleTickerProviderStateMixin {

  List expenses = [];
  bool isLoading = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final res = await ExpenseService.getExpenses();
    setState(() {
      expenses = res;
      isLoading = false;
    });
  }

  List filteredExpenses(int index) {
    if (index == 0) return expenses;
    if (index == 1) return expenses.where((e) => e["status"] == "pending").toList();
    if (index == 2) return expenses.where((e) => e["status"] == "approved").toList();
    return expenses.where((e) => e["status"] == "rejected").toList();
  }

  Color statusColor(String s) {
    if (s == "approved") return Colors.green;
    if (s == "rejected") return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      Navigator.pop(context, true);
      return false;
    },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
      
        appBar: AppBar(
          title: const Text("Expenses"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: TabBar(
            controller: tabController,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "All"),
              Tab(text: "Pending"),
              Tab(text: "Approved"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
      
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final r = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            );
            if (r == true) loadExpenses();
          },
          label: const Text("Add Expense"),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xFF6A11CB),
        ),
      
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          controller: tabController,
          children: List.generate(4, (tabIndex) {
            final list = filteredExpenses(tabIndex);
      
            return RefreshIndicator(
              onRefresh: loadExpenses,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final e = list[i];
      
                  return Dismissible(
                    key: Key(e["expense_id"].toString()),
      
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
      
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
      
                    confirmDismiss: (direction) async {
                      if (e["status"] != "pending") return false;
      
                      if (direction == DismissDirection.startToEnd) {
                        await ExpenseService.approveExpense(e["expense_id"]);
                        loadExpenses();
                        return false;
                      } else {
                        await ExpenseService.deleteExpense(e["expense_id"]);
                        loadExpenses();
                        return false;
                      }
                    },
      
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6)
                        ],
                      ),
      
                      child: Row(
                        children: [
      
                          CircleAvatar(
                            backgroundColor: const Color(0xFF6A11CB),
                            child: const Icon(Icons.receipt, color: Colors.white),
                          ),
      
                          const SizedBox(width: 12),
      
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
      
                                Text(
                                  e["category_name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
      
                                Text(e["description"] ?? ""),
      
                                const SizedBox(height: 4),
      
                                Text(
                                  e["status"].toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor(e["status"]),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
      
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
      
                              Text(
                                "LKR ${e["amount"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
      
                              if (e["status"] == "pending")
                                Row(
                                  children: [
      
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      onPressed: () async {
                                        await ExpenseService.approveExpense(e["expense_id"]);
                                        loadExpenses();
                                      },
                                    ),
      
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () async {
                                        await ExpenseService.rejectExpense(e["expense_id"]);
                                        loadExpenses();
                                      },
                                    ),
      
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () async {
                                        final r = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditExpenseScreen(expense: e),
                                          ),
                                        );
                                        if (r == true) loadExpenses();
                                      },
                                    ),
      
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        try {
                                          await ExpenseService.deleteExpense(e["expense_id"]);
                                          loadExpenses();
                                        } catch (_) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Only pending expenses can be deleted"),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}