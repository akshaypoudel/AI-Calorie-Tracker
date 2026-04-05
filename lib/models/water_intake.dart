class WaterIntake {
  final int? id;
  final String date;
  int cups;

  WaterIntake({this.id, required this.date, required this.cups});

  Map<String, dynamic> toMap() => {'id': id, 'date': date, 'cups': cups};

  factory WaterIntake.fromMap(Map<String, dynamic> map) =>
      WaterIntake(id: map['id'], date: map['date'], cups: map['cups']);
}
