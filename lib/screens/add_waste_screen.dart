import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddWasteScreen extends StatefulWidget {
  final String? userType;

  const AddWasteScreen({super.key, this.userType});

  @override
  State<AddWasteScreen> createState() => _AddWasteScreenState();
}

class _AddWasteScreenState extends State<AddWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _gramsController = TextEditingController();

  String? _selectedFoodType;
  final List<String> _foodTypes = [
    'Vegetables',
    'Fruits',
    'Bread',
    'Meat',
    'Other'
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _saveWaste() async {
    if (_formKey.currentState!.validate() && _selectedFoodType != null) {
      final grams = int.parse(_gramsController.text);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("No logged-in user");

        final enteredByRole = widget.userType ?? 'Unknown Role';

        await _firestore.collection('waste').add({
          'grams': grams,
          'foodType': _selectedFoodType!,
          'date': Timestamp.now(),
          'enteredBy': enteredByRole,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Waste data added successfully")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding waste: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select food type")),
      );
    }
  }

  // ✅ SAME button style as Admin/Home
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Add Waste",
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Waste Amount
                            TextFormField(
                              controller: _gramsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Waste Amount (grams)",
                                prefixIcon: const Icon(Icons.scale),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Enter amount in grams";
                                }
                                if (int.tryParse(v) == null ||
                                    int.parse(v) <= 0) {
                                  return "Enter a valid number";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Food Type
                            DropdownButtonFormField<String>(
                              value: _selectedFoodType,
                              decoration: InputDecoration(
                                labelText: "Food Type",
                                prefixIcon: const Icon(Icons.fastfood),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              items: _foodTypes
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedFoodType = val),
                              validator: (v) =>
                                  v == null ? "Select food type" : null,
                            ),
                            const SizedBox(height: 32),

                            // Save Button
                            Center(
                              child: SizedBox(
                                width: 220,
                                child: _highlightButton(
                                  label: "Save Waste",
                                  onPressed: _saveWaste,
                                ),
                              ),
                            ),
                          ],
                        ),
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
}
