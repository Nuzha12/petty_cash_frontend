import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/token_service.dart';
import '../../../core/constants/api_constants.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map data = {};
  bool loading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) load();
    });
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    String type = "monthly";
    if (_tabController.index == 0) type = "daily";
    if (_tabController.index == 2) type = "annual";

    String url = "/reports?type=$type&month=${selectedDate.month}&year=${selectedDate.year}";
    if (type == "daily") {
      url += "&date=${DateFormat('yyyy-MM-dd').format(selectedDate)}";
    }

    try {
      final res = await ApiService.request("GET", url);
      setState(() {
        data = res ?? {};
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      load();
    }
  }

  Future<void> _downloadCSV() async {
    setState(() => loading = true);
    try {
      await ApiService.downloadReport(selectedDate.month, selectedDate.year);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report downloaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List transactions = data['transactions'] ?? [];
    final double totalExpenses = double.tryParse(data['total_expenses']?.toString() ?? "0") ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Financial Reports"),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _downloadCSV),
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickDate),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Daily"), Tab(text: "Monthly"), Tab(text: "Annual")],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildSummaryHeader(totalExpenses),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("No transactions found for this period"))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, i) => _buildTransactionCard(transactions[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(double total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tabController.index == 0
                ? DateFormat('yMMMd').format(selectedDate)
                : DateFormat('MMMM yyyy').format(selectedDate),
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Total Expenses", style: TextStyle(color: Colors.white, fontSize: 16)),
          Text(
            "LKR ${total.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(dynamic t) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.1),
          child: const Icon(Icons.receipt_long, color: Colors.teal),
        ),
        title: Text(t['category'] ?? "General", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t['description'] ?? "No description", maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(t['date'] ?? "", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: Text(
          "LKR ${(t['amount'] as num).toDouble().toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}