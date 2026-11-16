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
                BarChartRodData(
                    toY: budget,
                    color: Colors.blueAccent,
                    width: 12,
                    borderRadius: BorderRadius.circular(4)
                ),
                BarChartRodData(
                    toY: used,
                    color: Colors.redAccent,
                    width: 12,
                    borderRadius: BorderRadius.circular(4)
                ),
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[index]["category"] ?? "",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}