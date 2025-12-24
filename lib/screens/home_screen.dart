import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_waste_screen.dart';
import 'rewards_screen.dart';
import 'weekly_report_screen.dart';
import 'admin_screen.dart';
import 'login_screen.dart'; // ✅ ADD THIS

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

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    setState(() {
      todayWaste = 500;
      weekWaste = 3200;
      points = 120;

      recentLogs = List.generate(6, (index) {
        return {
          "grams": 80 + index * 40,
          "foodType": "Rice",
          "enteredBy": widget.userType ?? "General",
          "date": DateTime.now().subtract(Duration(hours: index * 4)),
        };
      });
    });
  }

  void _addWaste(int grams, String foodType, String enteredBy) {
    setState(() {
      todayWaste += grams;
      weekWaste += grams;
      points += grams ~/ 10;

      recentLogs.insert(0, {
        "grams": grams,
        "foodType": foodType,
        "enteredBy": enteredBy,
        "date": DateTime.now(),
      });
    });
  }

  void _clearData() {
    setState(() {
      todayWaste = 0;
      weekWaste = 0;
      points = 0;
      recentLogs.clear();
    });
  }

  int _calculateLastWeekWaste() {
    final now = DateTime.now();
    int total = 0;
    for (var log in recentLogs) {
      final date = log['date'] as DateTime;
      if (date.isBefore(DateTime(now.year, now.month, now.day))) {
        total += log['grams'] as int;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // 🔹 APP BAR WITH LOGIN REDIRECT
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
                MaterialPageRoute(
                  builder: (_) => WeeklyReportScreen(
                    thisWeek: weekWaste,
                    lastWeek: _calculateLastWeekWaste(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RewardScreen(points: points),
                ),
              );
            },
          ),
        ],
      ),

      // 🔹 BACKGROUND
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
                          MaterialPageRoute(builder: (_) => const AdminScreen()),
                        );
                      },
                      icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
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
                    MaterialPageRoute(
                      builder: (_) => AddWasteScreen(onAddWaste: _addWaste),
                    ),
                  );
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
