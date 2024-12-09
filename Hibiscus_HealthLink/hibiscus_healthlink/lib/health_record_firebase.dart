import 'package:cloud_firestore/cloud_firestore.dart';


class HealthRecord {
  final DateTime date;
  final double value;

  HealthRecord({required this.date, required this.value});

  factory HealthRecord.fromFirestore(Map<String, dynamic> data) {
    return HealthRecord(
      date: (data['date'] as Timestamp).toDate(),
      value: (data['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'value': value,
    };
  }
}
