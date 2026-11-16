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
    final double total = double.tryParse(rawTotal?.toString() ?? "0") ?? 0.0;

    final List categories = (data["categories"] as List?)
        ?.where((item) => item["value"] != null && (item["value"] as num) > 0)
        .toList() ?? [];

    final List budgets = data["budget_vs_actual"] ?? [];
    final List recent = data["recent_expenses"] ?? [];
    final String topCategory = data["top_category"] ?? "None";

    final now = DateTime.now();
    final dateString = "${now.month}/${now.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("Your Expenses", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildSummaryCard(total, dateString),
            const SizedBox(height: 30),

            if (categories.isNotEmpty) ...[
              const Text("Spending Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              CategoryChart(categories: categories),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Top Spending: $topCategory",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A00E0))),
                ),
              ),
            ],

            const SizedBox(height: 25),
            if (budgets.isNotEmpty) ...[
              const Text("Budget Watch", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...budgets.map((b) => _buildBudgetCard(b)),
            ],

            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen()));
                    load();
                  },
                  child: const Text("View All"),
                ),
              ],
            ),
            ...recent.map((e) => _buildTransactionTile(e)),

            const SizedBox(height: 30),
            _buildActionButton("Add New Expense", Icons.add_circle_outline, () async {
              final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
              if (res == true) load();
            }, isPrimary: true),
            const SizedBox(height: 12),
            _buildActionButton("Manage Budgets", Icons.account_balance_wallet_outlined, () async {
              final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetManagementScreen()));
              if (res == true) load();
            }),
            const SizedBox(height: 12),
            _buildActionButton("Financial Reports", Icons.analytics_outlined, () {
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
        boxShadow: [BoxShadow(color: const Color(0xFF4A00E0).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Monthly Spending", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(date, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            child: Text(
              "LKR ${total.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(dynamic b) {
    final double spent = double.tryParse(b["spent"]?.toString() ?? "0") ?? 0.0;
    final double budget = double.tryParse(b["budget"]?.toString() ?? "0") ?? 0.0;
    final double remaining = double.tryParse(b["remaining"]?.toString() ?? "0") ?? 0.0;

    final exceeded = spent > budget;
    final progress = (budget > 0) ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: exceeded ? Colors.red.shade100 : Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(b["category"] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(exceeded ? "Over Budget" : "Under Control",
                  style: TextStyle(color: exceeded ? Colors.red : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            color: exceeded ? Colors.red : const Color(0xFF4A00E0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("LKR ${spent.toStringAsFixed(0)} spent", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text("Rem: LKR ${remaining.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTransactionTile(dynamic e) {
    final status = e["status"]?.toString().toLowerCase() ?? "pending";
    final amount = double.tryParse(e["amount"]?.toString() ?? "0") ?? 0.0;
    Color statusColor = status == "approved" ? Colors.green : (status == "rejected" ? Colors.red : Colors.orange);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.receipt_long, color: statusColor, size: 20),
        ),
        title: Text(e["description"] ?? "Expense", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(e["date"] ?? "", style: const TextStyle(fontSize: 11)),
        trailing: Text("LKR ${amount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback action, {bool isPrimary = false}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF4A00E0) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF4A00E0),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          side: const BorderSide(color: Color(0xFF4A00E0)),
        ),
      ),
    );
  }
}