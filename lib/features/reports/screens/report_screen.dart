import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map data = {};
  bool loading = true;
  DateTime? selectedDate;

  int month = DateTime.now().month;
  int year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => selectedDate = null);
        load();
      }
    });
    load();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _tabController.index = 0;
      });
      load();
    }
  }

  Future load() async {
    setState(() => loading = true);

    String type = "monthly";
    if (_tabController.index == 0) type = "daily";
    if (_tabController.index == 2) type = "annual";

    String url = "/reports?type=$type&month=$month&year=$year";
    if (selectedDate != null && _tabController.index == 0) {
      url += "&date=${DateFormat('yyyy-MM-dd').format(selectedDate!)}";
    }

    final res = await ApiService.request("GET", url);

    setState(() {
      data = res ?? {};
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = data['categories'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDate,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Daily"),
            Tab(text: "Monthly"),
            Tab(text: "Annual"),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (selectedDate != null && _tabController.index == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Chip(
                  label: Text("Date: ${DateFormat('yMMMd').format(selectedDate!)}"),
                  onDeleted: () {
                    setState(() => selectedDate = null);
                    load();
                  },
                ),
              ),
            if (_tabController.index == 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton(
                    value: month,
                    items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text("Month ${i + 1}"))),
                    onChanged: (v) {
                      setState(() => month = v as int);
                      load();
                    },
                  ),
                  DropdownButton(
                    value: year,
                    items: [2024, 2025, 2026].map((y) => DropdownMenuItem(value: y, child: Text("$y"))).toList(),
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Expense", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Text(
                    "LKR ${data['total_expenses'] ?? 0}",
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: categories.isEmpty
                  ? const Center(child: Text("No expenses found"))
                  : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final c = categories[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(c['category'] ?? "General"),
                      trailing: Text("LKR ${c['total']}", style: const TextStyle(fontWeight: FontWeight.bold)),
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