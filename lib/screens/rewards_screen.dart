// reward_screen.dart
import 'package:flutter/material.dart';

class RewardScreen extends StatefulWidget {
  final int points; // Pass points from HomeScreen

  const RewardScreen({super.key, this.points = 0});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late int _points;

  @override
  void initState() {
    super.initState();
    _points = widget.points;
  }

  String _levelName(int points) {
    if (points >= 500) return 'Eco Master';
    if (points >= 300) return 'Gold';
    if (points >= 150) return 'Silver';
    if (points >= 50) return 'Bronze';
    return 'Starter';
  }

  void _refresh() {
    setState(() {
      _points = _points; // Just refresh local points
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = _levelName(_points);

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
                      "Rewards",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _refresh,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Points Card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 56,
                              color: Colors.red.shade400, // changed to red
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "$_points pts",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF263238),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Level: $level",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF607D8B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Badges Title
                    const Text(
                      "Badges Unlocked",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Badges Wrap
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _badge("Bronze", 50),
                        _badge("Silver", 150),
                        _badge("Gold", 300),
                        _badge("Eco Master", 500),
                      ],
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

  // Badge Widget
  Widget _badge(String name, int requiredPoints) {
    final unlocked = _points >= requiredPoints;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? Colors.red.shade400 : Colors.grey.shade400, // unlocked = red
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Icon(
            Icons.star_rounded,
            size: 34,
            color: unlocked ? Colors.white : Colors.black38,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: unlocked ? Colors.white : Colors.black45,
          ),
        ),
        Text(
          "$requiredPoints pts",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
