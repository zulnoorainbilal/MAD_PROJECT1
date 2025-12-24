import 'package:flutter/material.dart';

class WeeklyReportScreen extends StatelessWidget {
  final int thisWeek;
  final int lastWeek;

  const WeeklyReportScreen({
    super.key,
    required this.thisWeek,
    required this.lastWeek,
  });

  @override
  Widget build(BuildContext context) {
    final diff = lastWeek - thisWeek;
    final percent = lastWeek == 0 ? 0.0 : (diff / lastWeek) * 100;

    final bool improved = thisWeek < lastWeek;
    final bool same = thisWeek == lastWeek;

    final String message = improved
        ? "Great job! You reduced ${percent.abs().toStringAsFixed(1)}% waste 🎉"
        : same
            ? "No change from last week 🙂"
            : "Waste increased. Try to reduce next week 💪";

    final Color msgColor = improved
        ? Colors.green.shade400
        : same
            ? Colors.orange.shade400
            : Colors.red.shade400;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top AppBar Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Weekly Report",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _statCard("This Week", "$thisWeek grams", Icons.calendar_today_outlined),
                    const SizedBox(height: 14),
                    _statCard("Last Week", "$lastWeek grams", Icons.history_outlined),
                    const SizedBox(height: 24),

                    // Message Card
                    Card(
                      color: Colors.white, // make card background white for contrast
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Icon(
                              improved
                                  ? Icons.thumb_up_alt_outlined
                                  : same
                                      ? Icons.info_outline
                                      : Icons.warning_amber_outlined,
                              color: msgColor,
                              size: 32,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87, // black text for readability
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Stat card like HomeScreen
  Widget _statCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white, // white card for contrast
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, size: 34, color: Colors.teal.shade400),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87, // black text
                    )),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // black text
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
