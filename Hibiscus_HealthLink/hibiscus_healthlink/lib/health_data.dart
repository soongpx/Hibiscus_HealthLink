import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthData extends ChangeNotifier {
  String userId = '';
  bool isLoading = false;

  List<Map<String, dynamic>> heartRates = [];
  List<Map<String, dynamic>> spO2Levels = [];
  List<Map<String, dynamic>> glucoseLevels = [];
  List<Map<String, dynamic>> cholesterolLevels = [];

  void setUserId(String uid) {
    if (userId == uid) return;
    userId = uid;
    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    if (userId.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final heartRateSnapshots = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('heartRates')
          .orderBy('date', descending: false)
          .get();

      heartRates = heartRateSnapshots.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'date': (data['date'] as Timestamp).toDate(),
          'value': (data['value'] as num).toDouble(),
        };
      }).toList();

      final spO2Snapshots = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('spO2Levels')
          .orderBy('date', descending: false)
          .get();

      spO2Levels = spO2Snapshots.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'date': (data['date'] as Timestamp).toDate(),
          'value': (data['value'] as num).toDouble(),
        };
      }).toList();

      final glucoseSnapshots = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('GlucoseLevels')
          .orderBy('date', descending: false)
          .get();

      glucoseLevels = glucoseSnapshots.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'date': (data['date'] as Timestamp).toDate(),
          'value': (data['value'] as num).toDouble(),
        };
      }).toList();

      final cholesterolSnapshots = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('CholesterolLevels')
          .orderBy('date', descending: false)
          .get();

      cholesterolLevels = cholesterolSnapshots.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'date': (data['date'] as Timestamp).toDate(),
          'value': (data['value'] as num).toDouble(),
        };
      }).toList();
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHeartRate(DateTime date, double value) async {
    if (userId.isEmpty) return;
    Map<String, Object> item = {'date': date, 'value': value};
    heartRates.add(item);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('heartRates')
        .add({'date': date, 'value': value}).then((documentSnapshot) =>
            debugPrint("Added Data with ID: ${documentSnapshot.id}"));
  }

  Future<void> addSpO2Level(DateTime date, double value) async {
    if (userId.isEmpty) return;
    Map<String, Object> item = {'date': date, 'value': value};
    spO2Levels.add(item);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('spO2Levels')
        .add({'date': date, 'value': value});
  }

  Future<void> addGlucoseLevel(DateTime date, double value) async {
    if (userId.isEmpty) return;
    Map<String, Object> item = {'date': date, 'value': value};
    glucoseLevels.add(item);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('GlucoseLevels')
        .add({'date': date, 'value': value});
  }

  Future<void> addCholesterolLevel(DateTime date, double value) async {
    if (userId.isEmpty) return;
    Map<String, Object> item = {'date': date, 'value': value};
    cholesterolLevels.add(item);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('CholesterolLevels')
        .add({'date': date, 'value': value});
  }
}
