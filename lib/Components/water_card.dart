import 'dart:developer';

import 'package:ai_calorie_counter/Components/card_wrapper.dart';
import 'package:ai_calorie_counter/models/water_intake.dart';
import 'package:ai_calorie_counter/repository/app_repository.dart';
import 'package:flutter/material.dart';

class WaterCard extends StatefulWidget {
  const WaterCard({super.key, required this.selectedDate});
  final DateTime selectedDate;
  @override
  State<WaterCard> createState() => WaterCardState();
}

class WaterCardState extends State<WaterCard> {
  bool _isExpanded = false;
  int cups = 0;
  static const double cupMl = 300.0;
  static const double goalL = 4.0;

  final AppRepository _repo = AppRepository();

  @override
  void initState() {
    super.initState();
    log('water date ------ ${widget.selectedDate}');
    loadData();
  }

  @override
  void didUpdateWidget(covariant WaterCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDate != widget.selectedDate) {
      log('Date changed → reload water data');

      loadData(); // 🔥 THIS is the fix
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _addCup() {
    setState(() {
      if (cups < 20) {
        cups++;
      }
    });
    saveData();
  }

  void _removeCup() {
    if (cups > 0) {
      setState(() => cups--);
      saveData();
    }
  }

  Future<void> loadData() async {
    final date = widget.selectedDate.toIso8601String().split('T')[0];

    final intake = await _repo.getWaterIntake(date);

    if (intake != null) {
      setState(() {
        cups = intake.cups;
      });
    } else {
      setState(() {
        cups = 0;
      });
    }
  }

  Future<void> saveData() async {
    // final today = DateTime.now().toIso8601String().split('T')[0];
    final date = widget.selectedDate.toIso8601String().split('T')[0];
    final intake = WaterIntake(date: date, cups: cups);
    await _repo.saveWaterIntake(intake);
  }

  double get totalL => (cups * cupMl / 1000.0);
  double get progress => (totalL / goalL).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _toggleExpanded,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Water: ${totalL.toStringAsFixed(1)}L",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleExpanded,
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            // Collapsible content
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: _removeCup,
                    icon: const Icon(Icons.remove_circle_outline),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "$cups Cups",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _addCup,
                    icon: const Icon(Icons.add_circle_outline),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${(progress * 100).toStringAsFixed(0)}% to 4L goal"),
                  (goalL - totalL > 0)
                      ? Text(
                          "${(goalL - totalL).toStringAsFixed(1)}L remaining",
                        )
                      : Text(
                          'Goal Achieved 🎉',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
