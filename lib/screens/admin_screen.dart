import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> allWasteData = [];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    setState(() {
      allWasteData = List.generate(10, (index) {
        return {
          "grams": 50 + index * 20,
          "foodType": "Rice",
          "enteredBy": "User ${index + 1}",
          "date": DateTime.now().subtract(Duration(days: index)),
        };
      });
    });
  }

  void _deleteEntry(int index) {
    setState(() {
      allWasteData.removeAt(index);
    });
  }

  void _editEntry(int index) {
    final controller =
        TextEditingController(text: allWasteData[index]['grams'].toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () {
              setState(() {
                allWasteData[index]['grams'] =
                    int.tryParse(controller.text) ?? 0;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 Gradient Background
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
              // 🔹 Top AppBar Row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      "Admin Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.home, color: Colors.white),
                      tooltip: "Go to Home Screen",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const HomeScreen(userType: "Admin")),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 Waste Data List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allWasteData.length,
                  itemBuilder: (context, index) {
                    final e = allWasteData[index];
                    return Card(
                      color: Colors.white, // card color for contrast
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade400,
                          child: const Icon(Icons.restaurant, color: Colors.white),
                        ),
                        title: Text(
                          "${e['grams']}g • ${e['foodType']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        subtitle: Text(
                          "${e['enteredBy']} • ${DateFormat.yMMMd().add_jm().format(e['date'])}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editEntry(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEntry(index),
                            ),
                          ],
                        ),
                      ),
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
