import 'package:ai_calorie_counter/constants.dart';
import 'package:ai_calorie_counter/models/ai_log_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FoodLogCard extends StatelessWidget {
  final AILogEntry entry;

  const FoodLogCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final type = entry.data["type"] ?? "meal";

    if (type == "exercise") {
      return ExerciseCard(data: entry.data);
    }

    final items = (entry.data["items"] as List?) ?? const [];
    final totals = (entry.data["totals"] as Map?) ?? const {};

    final int totalCalories = _toDouble(totals["calories"]);
    final int totalCarbs = _toDouble(totals["carbs"]);
    final int totalProtein = _toDouble(totals["protein"]);
    final int totalFat = _toDouble(totals["fat"]);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            color: Color(0x12000000),
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          for (int i = 0; i < items.length; i++) ...[
            _FoodItemBlockCompact(item: items[i] as Map),
            if (i != items.length - 1) ...[
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 10),
            ],
          ],

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _MacroTotalCompact(
                  label: "Calories",
                  valueText: totalCalories.toString(),
                  percentText: _percentText(
                    totalCalories,
                    Constants.getDailyCalories(),
                  ),
                  progress: _progress(
                    totalCalories,
                    Constants.getDailyCalories(),
                  ),
                  color: _MacroColors.calories,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroTotalCompact(
                  label: "Carbs",
                  valueText: "${totalCarbs}g",
                  percentText: _percentText(
                    totalCarbs,
                    Constants.getDailyCarbs(),
                  ),
                  progress: _progress(totalCarbs, Constants.getDailyCarbs()),
                  color: _MacroColors.carbs,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroTotalCompact(
                  label: "Protein",
                  valueText: "${totalProtein}g",
                  percentText: _percentText(
                    totalProtein,
                    Constants.getDailyProtein(),
                  ),
                  progress: _progress(
                    totalProtein,
                    Constants.getDailyProtein(),
                  ),
                  color: _MacroColors.protein,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroTotalCompact(
                  label: "Fat",
                  valueText: "${totalFat}g",
                  percentText: _percentText(totalFat, Constants.getDailyFat()),
                  progress: _progress(totalFat, Constants.getDailyFat()),
                  color: _MacroColors.fat,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            DateFormat("h:mm a").format(entry.time),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }

  static int _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _progress(int value, int max) {
    if (max <= 0) return 0;
    return (value / max).clamp(0.0, 1.0);
  }

  static String _percentText(int value, int max) {
    if (max <= 0) return "0%";
    return "${(value / max * 100).round()}%";
  }
}

class _FoodItemBlockCompact extends StatelessWidget {
  final Map item;
  const _FoodItemBlockCompact({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = (item["name"] ?? "").toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _MacroChipCompact(
              label: "Calories",
              value: (item["calories"] ?? 0).toString(),
              color: _MacroColors.calories,
              icon: Icons.local_fire_department_rounded,
            ),
            _MacroChipCompact(
              label: "Carbs",
              value: "${item["carbs"] ?? 0}g",
              color: _MacroColors.carbs,
              icon: Icons.grain_rounded,
            ),
            _MacroChipCompact(
              label: "Protein",
              value: "${item["protein"] ?? 0}g",
              color: _MacroColors.protein,
              icon: Icons.fitness_center_rounded,
            ),
            _MacroChipCompact(
              label: "Fat",
              value: "${item["fat"] ?? 0}g",
              color: _MacroColors.fat,
              icon: Icons.opacity_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroChipCompact extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MacroChipCompact({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color.withValues(alpha: 0.10);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroTotalCompact extends StatelessWidget {
  final String label;
  final String valueText;
  final String percentText;
  final double progress;
  final Color color;

  const _MacroTotalCompact({
    required this.label,
    required this.valueText,
    required this.percentText,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          valueText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5, // thinner bar [web:8]
            backgroundColor: color.withValues(alpha: 0.14),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          percentText,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MacroColors {
  static const calories = Color(0xFFE53935);
  static const carbs = Color(0xFF1E88E5);
  static const protein = Color(0xFFFFB300);
  static const fat = Color(0xFF8E24AA);
}

class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ExerciseCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final activity = (data["activity"] ?? "Exercise").toString();
    final duration = _toInt(data["duration_minutes"]);
    final calories = _toInt(data["calories_burned"]);

    // Color theme for exercise
    const accent = Color(0xFF2E7D32); // green
    final bg = accent.withValues(alpha: 0.10);

    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 5),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 14,
              color: Color(0x12000000),
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading icon badge
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.20)),
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                size: 18,
                color: accent,
              ),
            ),
            const SizedBox(width: 10),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MiniChip(
                        icon: Icons.timer_rounded,
                        label: "Duration",
                        value: "$duration min",
                        color: const Color(0xFF1E88E5), // blue
                      ),
                      _MiniChip(
                        icon: Icons.local_fire_department_rounded,
                        label: "Burned",
                        value: "$calories kcal",
                        color: const Color(0xFFE53935), // red
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.round();
    return int.tryParse(v.toString()) ?? 0;
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              height: 1.1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
