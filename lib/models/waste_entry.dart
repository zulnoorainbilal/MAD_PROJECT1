class WasteEntry {
  final String foodName;
  final int quantity;
  final DateTime date;
  final bool donated;

  WasteEntry({
    required this.foodName,
    required this.quantity,
    required this.date,
    this.donated = false,
  });
}
