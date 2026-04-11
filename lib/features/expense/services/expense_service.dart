import '../../../core/services/api_service.dart';

class ExpenseService {

  static Future<List<dynamic>> getExpenses() async {
    final res = await ApiService.request("GET", "/expenses/");
    return res is List ? res : [];
  }

  static Future<void> addExpense(Map<String, dynamic> data) async {
    await ApiService.request("POST", "/expenses/", data: data);
  }

  static Future<void> updateExpense(int id, Map<String, dynamic> data) async {
    await ApiService.request("PATCH", "/expenses/$id", data: data);
  }

  static Future<void> deleteExpense(int id) async {
    await ApiService.request("DELETE", "/expenses/$id");
  }

  static Future<void> approveExpense(int id) async {
    await ApiService.request("PATCH", "/expenses/$id/approve");
  }

  static Future<void> rejectExpense(int id) async {
    await ApiService.request("PATCH", "/expenses/$id/reject");
  }

  static Future<List<dynamic>> getBudgets() async {
    final res = await ApiService.request("GET", "/budgets/");
    return res is List ? res : [];
  }

  static Future<void> setBudget(Map<String, dynamic> data) async {
    await ApiService.request("POST", "/budgets/", data: data);
  }
}