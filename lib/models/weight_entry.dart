class WeightEntry {
  final double weight;
  final DateTime date;

  WeightEntry(this.weight, this.date);

  Map<String, dynamic> toMap() => {
    'weight': weight,
    'date': date.millisecondsSinceEpoch,
  };

  factory WeightEntry.fromMap(Map<String, dynamic> map) => WeightEntry(
    (map['weight'] as num).toDouble(),
    DateTime.fromMillisecondsSinceEpoch((map['date'] as num).toInt()),
  );
}
