class Expense {
  final int id;
  final double amount;
  final String category;
  final String description;
  final String date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["expense_id"],
      amount: (json["amount"] as num).toDouble(),
      category: json["category"],
      description: json["description"] ?? "",
      date: json["expense_date"],
    );
  }
}