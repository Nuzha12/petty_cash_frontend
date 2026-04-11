import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/token_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../budget/screens/budget_management_screen.dart';
import '../../expense/screens/add_expense_screen.dart';
import '../../expense/screens/expense_list_screen.dart';
import '../widgets/category_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map data = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      final res = await ApiService.request("GET", "/dashboard/");
      if (mounted) {
        setState(() {
          data = res ?? {};
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  void _logout() async {
    await TokenService().clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dynamic rawTotal = data["total_expenses"];
    final double total = (rawTotal is num) ? rawTotal.toDouble() : 0.0;

    final List categories = (data["categories"] as List?)?.where((item) => item["value"] != null).toList() ?? [];
    final List budgets = data["budget_vs_actual"] ?? [];
    final List recent = data["recent_expenses"] ?? [];
    final String topCategory = data["top_category"] ?? "-";

    final now = DateTime.now();
    final dateString = "${now.month}/${now.year}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Your Expenses",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 15),
            _buildSummaryCard(total, dateString),
            const SizedBox(height: 30),
            if (categories.isNotEmpty) ...[
              const Text("Spending Breakdown",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              CategoryChart(categories: categories),
              const SizedBox(height: 10),
              Text("Top Category: $topCategory",
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurple)),
            ],
            const SizedBox(height: 25),
            if (budgets.isNotEmpty) ...[
              const Text("Budget vs Actual",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...budgets.map((b) => _buildBudgetCard(b)),
            ],
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Transactions",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpenseListScreen()));
                    load();
                  },
                  child: const Text("See more"),
                ),
              ],
            ),
            ...recent.map((e) => _buildTransactionTile(e)),
            const SizedBox(height: 30),
            _buildActionButton("Add Expense", Icons.add, () async {
              final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddExpenseScreen()));
              if (res == true) load();
            }),
            const SizedBox(height: 12),
            _buildActionButton("Set Budget", Icons.account_balance_wallet,
                    () async {
                  final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BudgetManagementScreen()));
                  if (res == true) load();
                }),
            const SizedBox(height: 12),
            _buildActionButton("View Reports", Icons.bar_chart, () {
              Navigator.pushNamed(context, '/reports');
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double total, String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF4A00E0).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Approved Expenses",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(date,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text("Monthly Spending",
              style: TextStyle(color: Colors.white60, fontSize: 14)),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(
              "LKR ${total.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(dynamic b) {
    final spent = double.tryParse(b["spent"]?.toString() ?? "0") ?? 0.0;
    final budget = double.tryParse(b["budget"]?.toString() ?? "0") ?? 0.0;
    final remaining = double.tryParse(b["remaining"]?.toString() ?? "0") ?? 0.0;

    final exceeded = spent > budget;
    final progress = budget == 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: exceeded ? Colors.red.shade200 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(b["category"] ?? "Category",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(exceeded ? "Exceeded" : "On Track",
                  style: TextStyle(
                      color: exceeded ? Colors.red : Colors.green,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
              value: progress,
              color: exceeded ? Colors.red : Colors.green,
              backgroundColor: Colors.grey.shade200,
              minHeight: 6),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Spent: LKR ${spent.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 13)),
              Text("Rem: LKR ${remaining.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(dynamic e) {
    final status = e["status"]?.toString().toLowerCase() ?? "pending";
    final amount = double.tryParse(e["amount"]?.toString() ?? "0") ?? 0.0;
    Color statusColor = status == "approved"
        ? Colors.green
        : (status == "rejected" ? Colors.red : Colors.orange);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        leading: const CircleAvatar(
            backgroundColor: Color(0xFFF3E5F5),
            child: Icon(Icons.receipt_long, color: Colors.purple)),
        title: Text(e["description"] ?? "No description",
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Row(
          children: [
            Text(e["date"] ?? "", style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            )
          ],
        ),
        trailing: Text("LKR ${amount.toStringAsFixed(2)}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4A00E0),
          side: const BorderSide(color: Color(0xFF4A00E0)),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}