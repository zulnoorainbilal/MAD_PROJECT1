import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  late Future<Map<String, int>> _weeklyFuture;

  @override
  void initState() {
    super.initState();
    _weeklyFuture = _calculateWeeklyWaste();
  }

  void _recalculate() {
    setState(() {
      _weeklyFuture = _calculateWeeklyWaste();
    });
  }

  // ✅ FIXED Firestore + Date Logic
  Future<Map<String, int>> _calculateWeeklyWaste() async {
    final now = DateTime.now();

    final startOfThisWeek =
        DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));

    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfThisWeek.subtract(const Duration(seconds: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('waste') // ✅ CORRECT collection
        .get();

    int thisWeek = 0;
    int lastWeek = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final Timestamp? ts = data['date']; // ✅ CORRECT field

      if (ts == null) continue;

      final date = ts.toDate();

      if (date.isAfter(startOfThisWeek)) {
        thisWeek += (data['grams'] ?? 0) as int;
      } else if (date.isAfter(startOfLastWeek) &&
          date.isBefore(endOfLastWeek)) {
        lastWeek += (data['grams'] ?? 0) as int;
      }
    }

    return {
      'thisWeek': thisWeek,
      'lastWeek': lastWeek,
    };
  }

  @override
  Widget build(BuildContext context) {
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
              // AppBar
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
                    const Spacer(),

                    // ✅ Recalculate Button (UI-safe)
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _recalculate,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: FutureBuilder<Map<String, int>>(
                  future: _weeklyFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final thisWeek = snapshot.data!['thisWeek']!;
                    final lastWeek = snapshot.data!['lastWeek']!;
                    final diff = lastWeek - thisWeek;
                    final percent =
                        lastWeek == 0 ? 0.0 : (diff / lastWeek) * 100;

                    final improved = thisWeek < lastWeek;
                    final same = thisWeek == lastWeek;

                    final message = improved
                        ? "Great job! You reduced ${percent.abs().toStringAsFixed(1)}% waste 🎉"
                        : same
                            ? "No change from last week 🙂"
                            : "Waste increased. Try to reduce next week 💪";

                    final msgColor = improved
                        ? Colors.green.shade400
                        : same
                            ? Colors.orange.shade400
                            : Colors.red.shade400;

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _statCard("This Week", "$thisWeek grams",
                            Icons.calendar_today_outlined),
                        const SizedBox(height: 14),
                        _statCard("Last Week", "$lastWeek grams",
                            Icons.history_outlined),
                        const SizedBox(height: 24),

                        Card(
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
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, size: 34, color: Colors.teal),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
