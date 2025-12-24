import 'package:flutter/material.dart';
import '../models/waste_entry.dart';

class WasteCard extends StatelessWidget {
  final WasteEntry entry;

  const WasteCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.restaurant_outlined,
          color: entry.donated ? Colors.green : Colors.orange,
        ),
        title: Text("${entry.foodName} - ${entry.quantity} g"),
        subtitle: Text(
          "Logged on: ${entry.date.day}/${entry.date.month}/${entry.date.year} ${entry.date.hour}:${entry.date.minute}",
        ),
        trailing: entry.donated
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    );
  }
}
