import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {

  Map data = {};
  bool loading = true;

  int month = DateTime.now().month;
  int year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    setState(() => loading = true);

    final res = await ApiService.request(
      "GET",
      "/dashboard?month=$month&year=$year",
    );

    setState(() {
      data = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final categories = data['categories'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                DropdownButton(
                  value: month,
                  items: List.generate(12, (i) {
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text("Month ${i + 1}"),
                    );
                  }),
                  onChanged: (v) {
                    setState(() => month = v as int);
                    load();
                  },
                ),

                DropdownButton(
                  value: year,
                  items: [2024, 2025, 2026].map((y) {
                    return DropdownMenuItem(value: y, child: Text("$y"));
                  }).toList(),
                  onChanged: (v) {
                    setState(() => year = v as int);
                    load();
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
                    "LKR ${data['total_expenses'] ?? 0}",
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
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final c = categories[i];
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
                        Text(c['category']),
                        Text("LKR ${c['total']}"),
                      ],
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