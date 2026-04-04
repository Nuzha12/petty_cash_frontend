import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {

  Map data = {};
  bool isLoading = true;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService.get(
        "/dashboard?month=$selectedMonth&year=$selectedYear",
      );

      if (!mounted) return;

      setState(() {
        data = res;
        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    final categories = data["categories"] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text("Month ${index + 1}"),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                    loadReport();
                  },
                ),

                DropdownButton<int>(
                  value: selectedYear,
                  items: [2024, 2025, 2026].map((y) {
                    return DropdownMenuItem(
                      value: y,
                      child: Text("$y"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                    loadReport();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Expense", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    "LKR ${data["total_expenses"] ?? 0}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: categories.isEmpty
                  ? const Center(
                child: Text(
                  "No data available",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final c = categories[index];

                  return Card(
                    child: ListTile(
                      title: Text(c["category"]),
                      trailing: Text("LKR ${c["total"]}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}