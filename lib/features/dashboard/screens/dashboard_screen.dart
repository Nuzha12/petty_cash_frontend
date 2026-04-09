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
    fetch();
  }

  Future fetch() async {
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

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_LK', symbol: 'LKR ');
    final now = DateTime.now();

    final categories = data['categories'] ?? [];
    final budgets = data['budget_vs_actual'] ?? [];
    final recent = data['recent_expenses'] ?? [];

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text("Your Expenses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

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
                Text("${now.month}/${now.year}", style: const TextStyle(color: Colors.white70)),
                Text(
                  fmt.format(toDouble(data['total_expenses'])),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text("Spending Breakdown", style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          pieChart(categories),

          const SizedBox(height: 20),

          const Text("Budget vs Actual", style: TextStyle(fontWeight: FontWeight.bold)),

          ...budgets.map((b) {
            double spent = toDouble(b['spent']);
            double budget = toDouble(b['budget']);
            double percent = budget == 0 ? 0 : spent / budget;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['category']),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: percent > 1 ? 1 : percent),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Spent: ${fmt.format(spent)}"),
                      Text("Remaining: ${fmt.format(budget - spent)}"),
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
              const Text("Recent Transactions", style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/expenses'),
                child: const Text("See more"),
              )
            ],
          ),

          ...recent.map((e) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.receipt),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e['description'] ?? "")),
                  Text(fmt.format(toDouble(e['amount'])))
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
                    final result = await Navigator.pushNamed(context, '/add');
                    if (result == true) fetch();
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
    );
  }

  Widget pieChart(List categories) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (_, double value, __) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 40,
                    sections: categories.map<PieChartSectionData>((e) {
                      return PieChartSectionData(
                        value: toDouble(e['total']) * value,
                        title: "${e['total']}",
                        color: getColor(e['category']),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Wrap(
                spacing: 10,
                children: categories.map<Widget>((e) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 5, backgroundColor: getColor(e['category'])),
                      const SizedBox(width: 5),
                      Text(e['category'])
                    ],
                  );
                }).toList(),
              )
            ],
          ),
        );
      },
    );
  }

  Color getColor(String name) {
    switch (name.toLowerCase()) {
      case 'food':
        return Colors.blue;
      case 'travel':
        return Colors.purple;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}