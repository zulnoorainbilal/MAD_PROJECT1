import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_waste_screen.dart';
import 'rewards_screen.dart';
import 'weekly_report_screen.dart';
import 'admin_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? userType;

  const HomeScreen({super.key, this.userType});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int todayWaste = 0;
  int weekWaste = 0;
  int points = 0;

  List<Map<String, dynamic>> recentLogs = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final snapshot = await _firestore
        .collection('waste')
        .orderBy('date', descending: true)
        .get();

    int todayTotal = 0;
    int weekTotal = 0;
    int totalPoints = 0;
    List<Map<String, dynamic>> logs = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final grams = data['grams'] as int;

      logs.add({
        'grams': grams,
        'foodType': data['foodType'],
        'enteredBy': data['enteredBy'],
        'date': date,
      });

      if (date.isAfter(startOfDay)) todayTotal += grams;
      if (date.isAfter(startOfWeek)) weekTotal += grams;

      totalPoints += grams ~/ 10; // same points calculation
    }

    setState(() {
      todayWaste = todayTotal;
      weekWaste = weekTotal;
      points = totalPoints;
      recentLogs = logs;
    });
  }

  Future<void> _addWaste(int grams, String foodType, String enteredBy) async {
    await _firestore.collection('waste').add({
      'grams': grams,
      'foodType': foodType,
      'enteredBy': enteredBy,
      'date': Timestamp.now(),
    });

    await _loadWasteData();
  }

  Future<void> _clearData() async {
    final snapshot = await _firestore.collection('waste').get();
    for (var doc in snapshot.docs) {
      await _firestore.collection('waste').doc(doc.id).delete();
    }
    await _loadWasteData();
  }

  int _calculateLastWeekWaste() {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfThisWeek.subtract(const Duration(seconds: 1));

    int total = 0;
    for (var log in recentLogs) {
      final date = log['date'] as DateTime;
      if (date.isAfter(startOfLastWeek) && date.isBefore(endOfLastWeek)) {
        total += log['grams'] as int;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
        title: const Text(
          "Eco Waste Tracker",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RewardScreen(points: points)),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.userType?.toLowerCase() == "admin")
                Center(
                  child: SizedBox(
                    width: 260,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Back to Admin Dashboard",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _statCard(
                title: "Today's Waste",
                value: "$todayWaste grams",
                buttonText: "Add Waste",
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddWasteScreen()),
                  );
                  await _loadWasteData();
                },
              ),
              const SizedBox(height: 14),
              _statCard(title: "This Week", value: "$weekWaste grams"),
              const SizedBox(height: 14),
              _statCard(title: "Points Earned", value: "$points pts"),
              const SizedBox(height: 26),
              const Text(
                "Recent Logs",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...recentLogs.map(
                (e) => Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant, color: Colors.teal),
                    title: Text("${e['grams']}g • ${e['foodType']}"),
                    subtitle: Text(
                      "${e['enteredBy']} • ${DateFormat.yMMMd().add_jm().format(e['date'])}",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _clearData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Clear All Data",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (buttonText != null)
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
