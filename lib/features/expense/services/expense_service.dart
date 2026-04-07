import '../../../core/services/api_service.dart';

class ExpenseService {

  static Future<List> getExpenses() async {
    return await ApiService.get("/expenses/");
  }

  static Future addExpense(Map<String, dynamic> data) async {
    return await ApiService.post("/expenses/", data);
  }

  static Future updateExpense(int id, Map<String, dynamic> data) async {
    return await ApiService.patch("/expenses/$id/", data);
  }

  static Future deleteExpense(int id) async {
    return await ApiService.delete("/expenses/$id/");
  }

  static Future approveExpense(int id) async {
    return await ApiService.patch("/expenses/$id/approve/", {});
  }

  static Future rejectExpense(int id) async {
    return await ApiService.patch("/expenses/$id/reject/", {});
  }
}