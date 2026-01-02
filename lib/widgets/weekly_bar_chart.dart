import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('waste').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final now = DateTime.now();

        // 🔹 Prepare last 7 days
        Map<String, double> dailyWaste = {};
        Map<String, String> dailyEnteredBy = {};

        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final label = DateFormat('EEE dd').format(date);
          dailyWaste[label] = 0;
          dailyEnteredBy[label] = "Unknown";
        }

        // 🔹 Fill from Firestore
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (data['date'] == null || data['grams'] == null) continue;

          final DateTime date = (data['date'] as Timestamp).toDate();
          final label = DateFormat('EEE dd').format(date);

          if (dailyWaste.containsKey(label)) {
            dailyWaste[label] =
                dailyWaste[label]! + (data['grams'] as num).toDouble();
            dailyEnteredBy[label] = data['enteredBy'] ?? "Unknown";
          }
        }

        final labels = dailyWaste.keys.toList();
        final values = dailyWaste.values.toList();

        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekly Waste (Last 7 Days)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.black87,
                          getTooltipItem:
                              (group, groupIndex, rod, rodIndex) {
                            final label = labels[groupIndex];
                            final enteredBy =
                                dailyEnteredBy[label] ?? "Unknown";

                            return BarTooltipItem(
                              '$label\n'
                              'Waste: ${rod.toY.toInt()} g\n'
                              'By: $enteredBy',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),

                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}g',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  labels[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      barGroups: List.generate(
                        values.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: values[index],
                              width: 18,
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.teal,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
