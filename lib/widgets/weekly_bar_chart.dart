import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key});

  static const List<String> entities = [
    "Admin",
    "Food Donor",
    "General Staff",
    "Resturant_Chef_Staff",
  ];

  static const Map<String, Color> entityColors = {
    "Admin": Colors.deepPurple,
    "Food Donor": Colors.orange,
    "General Staff": Colors.blue,
    "Resturant_Chef_Staff": Colors.green,
  };

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

        /// 🔹 Prepare last 7 days structure
        final List<DateTime> days = List.generate(
          7,
          (i) => DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: 6 - i)),
        );

        /// 🔹 date -> entity -> grams
        final Map<String, Map<String, double>> groupedData = {
          for (var d in days)
            DateFormat('EEE dd').format(d): {
              for (var e in entities) e: 0
            }
        };

        /// 🔹 Fill from Firestore
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['date'] == null ||
              data['grams'] == null ||
              data['enteredBy'] == null) continue;

          final DateTime date = (data['date'] as Timestamp).toDate();
          final String label = DateFormat('EEE dd').format(date);
          final String entity = data['enteredBy'];

          if (groupedData.containsKey(label) &&
              groupedData[label]!.containsKey(entity)) {
            groupedData[label]![entity] =
                groupedData[label]![entity]! +
                    (data['grams'] as num).toDouble();
          }
        }

        final labels = groupedData.keys.toList();

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
                  "Weekly Waste by Entity",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 280,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.black87,
                          getTooltipItem:
                              (group, groupIndex, rod, rodIndex) {
                            final date = labels[groupIndex];
                            final entity = entities[rodIndex];

                            return BarTooltipItem(
                              '$date\n'
                              '$entity\n'
                              '${rod.toY.toInt()} grams',
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

                      barGroups: List.generate(labels.length, (i) {
                        final dayData = groupedData[labels[i]]!;

                        return BarChartGroupData(
                          x: i,
                          barsSpace: 4,
                          barRods: List.generate(entities.length, (j) {
                            final entity = entities[j];
                            return BarChartRodData(
                              toY: dayData[entity]!,
                              width: 10,
                              borderRadius: BorderRadius.circular(4),
                              color: entityColors[entity],
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// 🔹 Legend
                Wrap(
                  spacing: 12,
                  children: entities.map((e) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: entityColors[e],
                        ),
                        const SizedBox(width: 6),
                        Text(e, style: const TextStyle(fontSize: 12)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
