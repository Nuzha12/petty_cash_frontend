import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
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
    setState(() => loading = true);

    try {
      final res = await ApiService.request("GET", "/dashboard/");
      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    final categories = data["categories"] ?? [];
    final budgets = data["budget_vs_actual"] ?? [];
    final recent = data["recent_expenses"] ?? [];
    final total = data["total_expenses"] ?? 0;
    final topCategory = data["top_category"] ?? "-";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: const [Icon(Icons.logout)],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            const Text("Your Expenses", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.blue],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("4/2026", style: TextStyle(color: Colors.white)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Total", style: TextStyle(color: Colors.white)),
                      Text(
                        "LKR $total",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (categories.isEmpty)
              const Center(child: Text("No expenses yet"))
            else ...[
              const Text("Spending Breakdown", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              CategoryChart(categories: categories),
            ],

            const SizedBox(height: 20),

            Column(
              children: categories.map<Widget>((c) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c["category"]),
                      Text("LKR ${c["total"]}")
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            Text("Top Category: $topCategory"),

            const SizedBox(height: 20),

            const Text("Budget vs Actual", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            ...budgets.map((b) {

              final spent = (b["spent"] as num).toDouble();
              final budget = (b["budget"] as num).toDouble();
              final remaining = b["remaining"];

              final exceeded = spent > budget;

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

                    Text(b["category"] ?? "Category"),

                    const SizedBox(height: 5),

                    LinearProgressIndicator(
                      value: budget == 0 ? 0 : spent / budget,
                      color: exceeded ? Colors.red : Colors.green,
                      backgroundColor: Colors.grey.shade300,
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Spent: LKR $spent"),
                        Text("Remaining: LKR $remaining")
                      ],
                    ),

                    if (exceeded)
                      const Text("Budget exceeded!", style: TextStyle(color: Colors.red))
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Recent Transactions", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("See more", style: TextStyle(color: Colors.blue))
              ],
            ),

            const SizedBox(height: 10),

            ...recent.map<Widget>((e) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e["description"]),
                        Text(e["date"], style: const TextStyle(fontSize: 12))
                      ],
                    ),
                    Text("LKR ${e["amount"]}")
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Add Expense"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {},
              child: const Text("View Reports"),
            ),
          ],
        ),
      ),
    );
  }
}