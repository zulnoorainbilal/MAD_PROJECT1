import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWasteScreen extends StatefulWidget {
  const AddWasteScreen({super.key});

  @override
  State<AddWasteScreen> createState() => _AddWasteScreenState();
}

class _AddWasteScreenState extends State<AddWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _gramsController = TextEditingController();

  String? _selectedFoodType;
  final List<String> _foodTypes = ['Vegetables', 'Fruits', 'Bread', 'Meat', 'Other'];

  String? _selectedEnteredBy;
  final List<String> _enteredByOptions = [
  'General Staff',
  'Food Donor',
  'Resturant_Chef_Staff',
  'Admin',
];


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _saveWaste() async {
    if (_formKey.currentState!.validate() &&
        _selectedFoodType != null &&
        _selectedEnteredBy != null) {
      final grams = int.parse(_gramsController.text);

      try {
        await _firestore.collection('waste').add({
          'grams': grams,
          'foodType': _selectedFoodType!,
          'enteredBy': _selectedEnteredBy!,
          'date': Timestamp.now(),
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
        const SnackBar(content: Text("Please select food type and entered by")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background like HomeScreen
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
              // AppBar replacement for gradient background
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
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Waste Amount
                            TextFormField(
                              controller: _gramsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Waste Amount (grams)",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.scale),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return "Enter amount in grams";
                                if (int.tryParse(v) == null || int.parse(v) <= 0) return "Enter a valid number";
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Food Type
                            DropdownButtonFormField<String>(
                              value: _selectedFoodType,
                              decoration: const InputDecoration(
                                labelText: "Food Type",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.fastfood),
                              ),
                              items: _foodTypes
                                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedFoodType = val),
                              validator: (v) => v == null ? "Select food type" : null,
                            ),
                            const SizedBox(height: 16),

                            // Entered By
                            DropdownButtonFormField<String>(
                              value: _selectedEnteredBy,
                              decoration: const InputDecoration(
                                labelText: "Entered By",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              items: _enteredByOptions
                                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedEnteredBy = val),
                              validator: (v) => v == null ? "Select who entered" : null,
                            ),
                            const SizedBox(height: 24),

                            // Save Waste Button
                            SizedBox(
                              width: 200,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _saveWaste,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Save Waste",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
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
