import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _wasteCollection;

  @override
  void initState() {
    super.initState();
    _wasteCollection = _firestore.collection('waste');
  }

  void _editEntry(DocumentSnapshot doc) {
    final controller =
        TextEditingController(text: (doc['grams'] ?? 0).toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Edit Waste"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Enter grams"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              int grams = int.tryParse(controller.text) ?? 0;
              await _wasteCollection.doc(doc.id).update({'grams': grams});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteEntry(DocumentSnapshot doc) async {
    await _wasteCollection.doc(doc.id).delete();
  }

  // ✅ Improved popup UI (same logic)
  void _clearAllData() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Clear All Data",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete ALL waste records?\nThis action cannot be undone.",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final snapshot = await _wasteCollection.get();
              for (var doc in snapshot.docs) {
                await doc.reference.delete();
              }
              Navigator.pop(context);
            },
            child: const Text("Delete All"),
          ),
        ],
      ),
    );
  }

  // Stat card
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal.withOpacity(0.15),
                child: Icon(icon, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Highlighted button
  Widget _highlightButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
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
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings,
                        color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    const Text(
                      "Admin Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _highlightButton(
                      label: "Home",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(userType: "Admin"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Stats
              StreamBuilder<QuerySnapshot>(
                stream: _wasteCollection.snapshots(),
                builder: (context, snapshot) {
                  int entries = 0;
                  int totalWaste = 0;
                  int todayWaste = 0;
                  int lastWeekWaste = 0;

                  final now = DateTime.now();
                  final startOfThisWeek =
                      now.subtract(Duration(days: now.weekday - 1));
                  final startOfLastWeek =
                      startOfThisWeek.subtract(const Duration(days: 7));
                  final endOfLastWeek =
                      startOfThisWeek.subtract(const Duration(seconds: 1));

                  if (snapshot.hasData) {
                    entries = snapshot.data!.docs.length;

                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final grams = (data['grams'] ?? 0) as int;
                      totalWaste += grams;

                      if (data['date'] != null) {
                        final date = (data['date'] as Timestamp).toDate();

                        if (date.year == now.year &&
                            date.month == now.month &&
                            date.day == now.day) {
                          todayWaste += grams;
                        }

                        if (date.isAfter(startOfLastWeek) &&
                            date.isBefore(endOfLastWeek)) {
                          lastWeekWaste += grams;
                        }
                      }
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _statCard(
                                title: "Entries",
                                value: "$entries",
                                icon: Icons.list_alt),
                            _statCard(
                                title: "Total Waste",
                                value: "$totalWaste g",
                                icon: Icons.delete_outline),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _statCard(
                                title: "Today",
                                value: "$todayWaste g",
                                icon: Icons.today),
                            _statCard(
                                title: "Last Week",
                                value: "$lastWeekWaste g",
                                icon: Icons.calendar_month),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ✅ Clear All Button (custom width + added height)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 52, // ✅ added height ONLY here
                    child: _highlightButton(
                      label: "Clear All Data",
                      onPressed: _clearAllData,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _wasteCollection
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No waste records found",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.withOpacity(0.2),
                              child: const Icon(Icons.restaurant,
                                  color: Colors.teal),
                            ),
                            title: Text(
                              "${data['grams']}g • ${data['foodType'] ?? 'Food'}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${data['enteredBy'] ?? 'User'}\n"
                              "${data['date'] != null ? DateFormat.yMMMd().add_jm().format((data['date'] as Timestamp).toDate()) : ''}",
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.teal),
                                  onPressed: () => _editEntry(doc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteEntry(doc),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
}
