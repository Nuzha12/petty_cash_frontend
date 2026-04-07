import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryChart extends StatelessWidget {
  final List categories;

  const CategoryChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {

    if (categories.isEmpty) {
      return const Center(
        child: Text("No chart data"),
      );
    }

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.teal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Spending Breakdown",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: List.generate(categories.length, (index) {
                final c = categories[index];
                final value = (c["total"] as num).toDouble();

                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: value,
                  radius: 60,
                  title: "${value.toInt()}",
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: List.generate(categories.length, (index) {
            final c = categories[index];

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  c["category"],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}