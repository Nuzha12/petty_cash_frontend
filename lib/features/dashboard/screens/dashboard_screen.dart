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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final now = DateTime.now();

      final res = await ApiService.get(
        "/dashboard?month=${now.month}&year=${now.year}",
      );

      if (!mounted) return;

      setState(() {
        data = res;
        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = data["categories"] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              ApiService.token = null;
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadData,
        child: categories.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(
              child: Text(
                "No expenses yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        )
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Your Expenses",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      "${DateTime.now().month}/${DateTime.now().year}",
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Total", style: TextStyle(color: Colors.white)),
                        Text(
                          "LKR ${data["total_expenses"] ?? 0}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              CategoryChart(categories: categories),

              const SizedBox(height: 20),

              ...categories.map<Widget>((c) {
                return Card(
                  child: ListTile(
                    title: Text(c["category"].toString()),
                    trailing: Text("LKR ${c["total"]}"),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              if (data["top_category"] != null)
                Text(
                  "Top Category: ${data["top_category"]}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

              const SizedBox(height: 20),

              const Text(
                "Budget vs Actual",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...(data["budget_vs_actual"] ?? []).map<Widget>((b) {

                final budget = b["budget"] ?? 0;
                final spent = b["spent"] ?? 0;
                final remaining = b["remaining"] ?? 0;

                final percent = budget == 0 ? 0 : (spent / budget);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Category ID: ${b["category_id"]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value: percent.clamp(0, 1),
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          color: percent >= 1 ? Colors.red : Colors.green,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Spent: LKR $spent"),
                            Text("Remaining: LKR $remaining"),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              const Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...(data["recent_expenses"] ?? []).map<Widget>((e) {

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(e["description"] ?? "No description"),
                    subtitle: Text(e["date"]),
                    trailing: Text("LKR ${e["amount"]}"),
                  ),
                );
              }).toList(),

              const SizedBox(height: 25),

              GestureDetector(
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/add-expense',
                  );

                  if (result == true) {
                    await loadData();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C9A7), Color(0xFF007CF0)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_circle, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Add Expense",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/reports');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.bar_chart, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "View Reports",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}