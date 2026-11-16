import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/token_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  Map<String, dynamic> _data = {"total_expenses": 0.0, "transactions": []};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _fetchReport();
      }
    });
    _fetchReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchReport() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final types = ["daily", "monthly", "annual"];
    final type = types[_tabController.index];
    final dateStr = DateTime.now().toIso8601String().split('T')[0];

    try {
       final res = await ApiService.request("GET", "/reports/?type=$type&month=$_month&year=$_year&date=$dateStr");
      if (mounted) {
        setState(() {
          _data = res ?? {"total_expenses": 0.0, "transactions": []};
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _downloadReport() async {
    final token = await TokenService().getToken();

    final String baseUrl = ApiConstants.baseUrl;
    final url = Uri.parse("$baseUrl/reports/download?month=$_month&year=$_year&token=$token");

    print("Attempting to download from: $url");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
     }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Financial Reports", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
              icon: const Icon(Icons.download_rounded, color: Color(0xFF4A00E0)),
              onPressed: _downloadReport
          ),
          IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {}
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Daily"), Tab(text: "Monthly"), Tab(text: "Annual")],
          indicatorColor: const Color(0xFF4A00E0),
          labelColor: const Color(0xFF4A00E0),
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)))
          : RefreshIndicator(
        onRefresh: _fetchReport,
        child: Column(
          children: [
            _buildHeaderCard(),
            Expanded(
              child: _data["transactions"] == null || _data["transactions"].isEmpty
                  ? const Center(child: Text("No transactions found for this period"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _data["transactions"].length,
                itemBuilder: (context, index) => _buildTransactionItem(_data["transactions"][index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final reportTitle = _tabController.index == 0 ? 'Daily' : _tabController.index == 1 ? 'Monthly' : 'Annual';
    final total = _data['total_expenses'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$reportTitle Expenses", style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            "LKR ${total.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(dynamic t) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0E7FF),
          child: const Icon(Icons.receipt_long, color: Color(0xFF4A00E0), size: 20),
        ),
        title: Text(t["category"] ?? "General", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(t["description"] ?? "No description", maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(
          "LKR ${(t["amount"] ?? 0.0).toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }
}