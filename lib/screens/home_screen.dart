import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(Duration(days: 7));
    final endOfLastWeek = startOfWeek.subtract(const Duration(seconds: 1));

    final wasteSnapshot = await _firestore
        .collection('waste')
        .orderBy('date', descending: true)
        .get();

    int todayTotal = 0;
    int weekTotal = 0;
    int lastWeekTotal = 0;
    List<Map<String, dynamic>> logs = [];

    for (var doc in wasteSnapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final int grams = (data['grams'] as num?)?.toInt() ?? 0;
      final String enteredBy = data['enteredBy'] ?? "Unknown Role";

      logs.add({
        'grams': grams,
        'foodType': data['foodType'] ?? 'Food',
        'enteredBy': enteredBy,
        'date': date,
      });

      if (date.isAfter(startOfDay)) todayTotal += grams;
      if (date.isAfter(startOfWeek)) weekTotal += grams;
      if (date.isAfter(startOfLastWeek) && date.isBefore(endOfLastWeek)) {
        lastWeekTotal += grams;
      }
    }

    // Points depend only on this week + last week
    int totalPoints = (weekTotal ~/ 100) + (lastWeekTotal ~/ 100);

    setState(() {
      todayWaste = todayTotal;
      weekWaste = weekTotal;
      points = totalPoints;
      recentLogs = logs;
    });
  }

  Future<void> _clearData() async {
    final snapshot = await _firestore.collection('waste').get();
    for (var doc in snapshot.docs) {
      await _firestore.collection('waste').doc(doc.id).delete();
    }
    await _loadWasteData();
  }

  Widget _highlightButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _appBarIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF00FFD5), Color(0xFF0072FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(1, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(5),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userType?.toLowerCase() == "admin";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: AppBar(
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
            title: Row(
              children: const [
                Icon(Icons.eco, color: Colors.white, size: 32),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Eco Waste Tracker",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              _appBarIcon(
                icon: Icons.bar_chart_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WeeklyReportScreen()),
                  );
                },
              ),
              _appBarIcon(
                icon: Icons.emoji_events_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RewardScreen(points: points)),
                  );
                },
              ),
            ],
          ),
        ),
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
              if (isAdmin) ...[
                Center(
                  child: SizedBox(
                    width: 220,
                    child: _highlightButton(
                      label: "Back To Admin Dashboard",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminScreen()),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              _statCard(
                title: "Today's Waste",
                value: "$todayWaste grams",
                buttonText: "Add Waste",
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddWasteScreen(userType: widget.userType),
                    ),
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
                    color: Colors.white),
              ),
              const SizedBox(height: 12),
              ...recentLogs.map(
                (e) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.restaurant, color: Colors.teal),
                    title: Text("${e['grams']}g • ${e['foodType']}"),
                    subtitle: Text(
                      "${e['enteredBy']} • ${DateFormat.yMMMd().add_jm().format(e['date'])}",
                    ),
                  ),
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 26),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: _highlightButton(
                      label: "Clear All Data",
                      onPressed: _clearData,
                    ),
                  ),
                ),
              ],
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
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (buttonText != null)
              _highlightButton(
                label: buttonText,
                onPressed: onPressed!,
              ),
          ],
        ),
      ),
    );
  }
}
