import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryChart extends StatelessWidget {
  final List categories;

  const CategoryChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {

    if (categories.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          "No expense data",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: List.generate(categories.length, (i) {
            final c = categories[i];

            return PieChartSectionData(
              value: (c["total"] as num).toDouble(),
              title: "",
              color: colors[i % colors.length],
              radius: 60,
            );
          }),
        ),
      ),
    );
  }
}