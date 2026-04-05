import 'dart:convert';

import 'package:ai_calorie_counter/models/ai_log_entry.dart';
import 'package:ai_calorie_counter/models/weight_entry.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';
import '../models/water_intake.dart';

extension WeightMethods on AppRepository {
  Future<void> deleteWeightEntry(WeightEntry entry) async {
    final db = await DatabaseHelper().database;

    await db.delete(
      'weight_entries',
      where: 'date = ?',
      whereArgs: [entry.date.millisecondsSinceEpoch],
    );
  }

  Future<void> updateWeightEntry(WeightEntry entry, double newWeight) async {
    final db = await DatabaseHelper().database;

    await db.update(
      'weight_entries',
      {'weight': newWeight},
      where: 'date = ?',
      whereArgs: [entry.date.millisecondsSinceEpoch],
    );
  }

  Future<void> saveWeightEntry(WeightEntry entry) async {
    final db = await DatabaseHelper().database;
    await db.insert('weight_entries', {
      'weight': entry.weight,
      'date': entry.date.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<WeightEntry>> getAllWeightEntries() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weight_entries',
      orderBy: 'date DESC',
    ); // Create table if needed
    return maps.map((map) => WeightEntry.fromMap(map)).toList();
  }
}

class AppRepository {
  Future<void> saveWaterIntake(WaterIntake intake) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      'water_intake',
      intake.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Upsert by date
    );
  }

  Future<WaterIntake?> getTodayIntake(String date) async {
    final db = await DatabaseHelper().database;
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final List<Map<String, dynamic>> maps = await db.query(
      'water_intake',
      where: 'date = ?',
      whereArgs: [today],
    );
    if (maps.isEmpty) return null;
    return WaterIntake.fromMap(maps.first);
  }

  // For other data
  Future<void> saveAppData(String key, String value) async {
    final db = await DatabaseHelper().database;
    await db.insert('app_data', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getAppData(String key) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_data',
      where: 'key = ?',
      whereArgs: [key],
    );
    return maps.isNotEmpty ? maps.first['value'] : null;
  }

  Future<void> saveMealLog(AILogEntry entry) async {
    final db = await DatabaseHelper().database;

    await db.insert('meal_logs', {
      'user_text': entry.title,
      'json_data': jsonEncode(entry.data),
      'created_at': entry.time.millisecondsSinceEpoch,
    });
  }

  Future<List<AILogEntry>> getMealLogs() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('meal_logs', orderBy: 'created_at DESC');

    return result.map((row) {
      return AILogEntry(
        title: row['user_text'] as String,
        data: jsonDecode(row['json_data'] as String),
        time: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );
    }).toList();
  }
}
