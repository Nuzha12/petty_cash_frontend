class Expense {
  final int id;
  final double amount;
  final String category;
  final String description;
  final String date;
  final String status;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.status,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["expense_id"],
      amount: (json["amount"] as num).toDouble(),
      category: json["category_name"] ?? json["category"] ?? "General",
      description: json["description"] ?? "",
      date: json["expense_date"] ?? "",
      status: json["status"] ?? "pending",
    );
  }
}