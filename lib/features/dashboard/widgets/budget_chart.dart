import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BudgetChart extends StatelessWidget {
  final List data;

  const BudgetChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(data.length, (index) {
            final item = data[index];

            final budget = (item["budget"] ?? 0).toDouble();
            final used = (item["used"] ?? 0).toDouble();

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(toY: budget),
                BarChartRodData(toY: used),
              ],
            );
          }),

          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= data.length) return const Text("");

                  return Text(
                    data[index]["category"] ?? "",
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}