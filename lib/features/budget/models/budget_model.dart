class Budget {
  final int budgetId;
  final int categoryId;
  final String categoryName;
  final double amount;
  final double spent;

  Budget({
    required this.budgetId,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.spent,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      budgetId: json['budget_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? 'Unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0,
    );
  }
}