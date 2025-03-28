import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class FuelChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  
  const FuelChart({
    super.key,
    required this.data,
    required this.title,
  });
  
  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: AppColors.textLight),
        ),
      );
    }
    
    // Determine min and max values for y-axis
    final efficiencyValues = data.map((entry) => entry['efficiency'] as double).toList();
    final minEfficiency = (efficiencyValues.reduce((a, b) => a < b ? a : b) * 0.8).roundToDouble();
    final maxEfficiency = (efficiencyValues.reduce((a, b) => a > b ? a : b) * 1.2).roundToDouble();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 2,
                  verticalInterval: 1,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          final date = DateTime.parse(data[value.toInt()]['date'] as String);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormatter.formatShortDate(date),
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                minX: 0,
                maxX: data.length.toDouble() - 1,
                minY: minEfficiency,
                maxY: maxEfficiency,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(data.length, (index) {
                      return FlSpot(
                        index.toDouble(), 
                        data[index]['efficiency'] as double
                      );
                    }),
                    isCurved: true,
                    color: AppColors.accent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.accent,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.accent.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
