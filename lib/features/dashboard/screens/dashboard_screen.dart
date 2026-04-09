import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';

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

  Future<void> load() async {
    final now = DateTime.now();

    final res = await ApiService.request(
      "GET",
      "/dashboard?month=${now.month}&year=${now.year}",
    );

    setState(() {
      data = res;
      loading = false;
    });
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

  Future confirmDelete() async {
    return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to delete?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final fmt = NumberFormat.currency(locale: 'en_LK', symbol: 'LKR ');
    final now = DateTime.now();

    final categories = data['categories'] ?? [];
    final budgets = data['budget_vs_actual'] ?? [];
    final recent = data['recent_expenses'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7F00FF), Color(0xFF00C6FF)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${now.month}/${now.year}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    fmt.format(toDouble(data['total_expenses'])),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text("Spending Breakdown",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            pieChart(categories),

            const SizedBox(height: 20),

            const Text("Budget vs Actual",
                style: TextStyle(fontWeight: FontWeight.bold)),

            ...budgets.map((b) {

              double spent = toDouble(b['spent']);
              double budget = toDouble(b['budget']);
              double remaining = budget - spent;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(b['category_name'] ?? "Unknown"),

                    const SizedBox(height: 6),

                    LinearProgressIndicator(
                      value: budget == 0 ? 0 : (spent / budget).clamp(0, 1),
                      color: remaining < 0 ? Colors.red : Colors.deepPurple,
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Spent: ${fmt.format(spent)}"),

                        remaining < 0
                            ? const Text(
                          "⚠ Over Budget",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            : Text("Remaining: ${fmt.format(remaining)}"),
                      ],
                    )
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Transactions",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/expenses'),
                  child: const Text("See more"),
                )
              ],
            ),

            ...recent.map((e) {

              final status = e['status'] ?? "pending";

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [

                    const Icon(Icons.receipt),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(e['description'] ?? ""),

                          Text(
                            status,
                            style: TextStyle(
                              color: getStatusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(fmt.format(toDouble(e['amount']))),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result =
                      await Navigator.pushNamed(context, '/add');
                      if (result == true) load();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Expense"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reports');
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text("View Reports"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget pieChart(List categories) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 40,
            sections: categories.map<PieChartSectionData>((e) {
              return PieChartSectionData(
                value: toDouble(e['total']),
                title: "",
                radius: 70,
                color: Colors.primaries[
                categories.indexOf(e) % Colors.primaries.length],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}