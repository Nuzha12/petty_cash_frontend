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
        child: SingleChildScrollView(
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
                    const Text("Total", style: TextStyle(color: Colors.white)),
                    Text(
                      "${data["total_expenses"] ?? 0}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              CategoryChart(categories: data["categories"] ?? []),

              const SizedBox(height: 20),

              ...(data["categories"] ?? []).map<Widget>((c) {
                return Card(
                  child: ListTile(
                    title: Text(c["category"].toString()),
                    trailing: Text("${c["total"]}"),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              if (data["top_category"] != null)
                Text(
                  "Top Category: ${data["top_category"]}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

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
            ],
          ),
        ),
      ),
    );
  }
}