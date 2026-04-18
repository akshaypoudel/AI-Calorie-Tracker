import 'dart:developer';

import 'package:ai_calorie_counter/Components/card_wrapper.dart';
import 'package:ai_calorie_counter/constants.dart';
import 'package:ai_calorie_counter/models/water_intake.dart';
import 'package:ai_calorie_counter/repository/app_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WaterCard extends StatefulWidget {
  const WaterCard({
    super.key,
    required this.selectedDate,
    required this.waterCups,
  });
  final DateTime selectedDate;
  final int waterCups;
  @override
  State<WaterCard> createState() => WaterCardState();
}

class WaterCardState extends State<WaterCard> {
  bool _isExpanded = false;
  int cups = 0;
  static const double cupMl = 250;
  double goalL = 2;
  bool isinit = true;

  final AppRepository _repo = AppRepository();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<Constants>(context, listen: true);
    final requiredWater = provider.getWaterCups.toDouble();
    goalL = (requiredWater * cupMl) / 1000;
  }

  @override
  void didUpdateWidget(covariant WaterCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDate != widget.selectedDate) {
      loadData(); // 🔥 THIS is the fix
    }
    loadData();
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

    log('goal litereererelllll ---- $goalL');
    final requiredWater = widget.waterCups.toDouble();
    goalL = (requiredWater * cupMl) / 1000;

    if (intake != null) {
      setState(() {
        cups = intake.cups;
      });
    } else {
      setState(() {
        cups = 0;
      });
    }
    setState(() {});
  }

  Future<void> saveData() async {
    final date = widget.selectedDate.toIso8601String().split('T')[0];
    final intake = WaterIntake(date: date, cups: cups);
    await _repo.saveWaterIntake(intake);
    setState(() {});
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
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}% to ${formatLiters(goalL)}L goal",
                  ),
                  (goalL - totalL > 0)
                      ? Text("${formatLiters((goalL - totalL))}L remaining")
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

  String formatLiters(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0); // 2
    } else if ((value * 10) % 1 == 0) {
      return value.toStringAsFixed(1); // 2.5
    } else {
      return value.toStringAsFixed(2); // 2.25
    }
  }
}
