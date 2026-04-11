import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryChart extends StatelessWidget {
  final List categories;

  const CategoryChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No spending data for this period"),
        ),
      );
    }

    final colors = [
      Colors.deepPurple,
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 50,
              sections: List.generate(categories.length, (index) {
                final c = categories[index];

                final dynamic rawValue = c["value"];
                final double value = (rawValue is num) ? rawValue.toDouble() : 0.0;

                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: value,
                  radius: 50,
                  title: value > 0 ? "${value.toInt()}" : "",
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
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: List.generate(categories.length, (index) {
            final c = categories[index];

            final String name = c["name"]?.toString() ?? "Other";

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}