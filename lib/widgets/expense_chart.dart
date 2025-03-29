import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class ExpenseChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  
  const ExpenseChart({
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
          style: TextStyle(color: AppColors.current.textLight),
        ),
      );
    }
    
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
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String month = data[groupIndex]['month'] as String;
                      double amount = data[groupIndex]['total'] as double;
                      return BarTooltipItem(
                        '${month}\n${DateFormatter.formatCurrency(amount)}',
                        TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          final month = data[value.toInt()]['month'] as String;
                          // Display just the month part
                          final monthOnly = month.split('-')[1];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              monthOnly,
                              style: TextStyle(
                                color: AppColors.current.textLight,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: TextStyle(
                            color: AppColors.current.textLight,
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
                  border: Border.all(color: AppColors.current.border, width: 1),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                ),
                barGroups: List.generate(data.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (data[index]['total'] as double),
                        color: AppColors.current.accent,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ExpensePieChart extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  
  const ExpensePieChart({
    super.key,
    required this.data,
    required this.title,
  });
  
  @override
  Widget build(BuildContext context) {
    final categoryExpenses = data['categoryExpenses'] as Map<String, double>;
    
    if (categoryExpenses.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: AppColors.current.textLight),
        ),
      );
    }
    
    // Generate colors for each category
    final List<Color> categoryColors = [
      AppColors.current.primary,
      AppColors.current.accent,
      AppColors.current.success,
      AppColors.current.warning,
      AppColors.current.danger,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    
    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;
    
    categoryExpenses.forEach((category, amount) {
      final double percentage = amount / (data['totalExpenses'] as double) * 100;
      
      sections.add(
        PieChartSectionData(
          color: categoryColors[colorIndex % categoryColors.length],
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      
      colorIndex++;
    });
    
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
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: categoryExpenses.length,
            itemBuilder: (context, index) {
              final category = categoryExpenses.keys.elementAt(index);
              final amount = categoryExpenses[category]!;
              final percentage = amount / (data['totalExpenses'] as double) * 100;
              
              return ListTile(
                leading: Container(
                  width: 16,
                  height: 16,
                  color: categoryColors[index % categoryColors.length],
                ),
                title: Text(category),
                trailing: Text(
                  '${DateFormatter.formatCurrency(amount)} (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
