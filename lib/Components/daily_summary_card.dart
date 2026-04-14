import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ai_calorie_counter/constants.dart';
import 'package:provider/provider.dart';

class DailySummaryCard extends StatelessWidget {
  final int food;
  final int exercise;
  final int remaining;

  final int carbs;
  final int protein;
  final int fat;

  const DailySummaryCard({
    super.key,
    required this.food,
    required this.exercise,
    required this.remaining,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 5.0;
    final provider = Provider.of<Constants>(context, listen: true);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ModernSummaryCard(
              title: "Calories",
              subtitle: "Today",
              icon: Icons.local_fire_department_rounded,
              accent: const Color(0xFFF59E0B),
              children: [
                const SizedBox(height: 12),
                Column(
                  children: [
                    _CalTile(value: food, label: "Food"),
                    const SizedBox(height: 10),
                    _CalTile(value: exercise, label: "Exercise"),
                    const SizedBox(height: 10),
                    _CalTile(
                      value: remaining,
                      label: "Remaining",
                      emphasize: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: gap),
          Expanded(
            child: _ModernSummaryCard(
              title: "Macros",
              subtitle: "Goal vs eaten",
              icon: Icons.donut_large_rounded,
              accent: const Color(0xFFDB2777),
              children: [
                const SizedBox(height: 12),
                _MacroRow(
                  label: "Carbs",
                  value: carbs,
                  goal: provider.getDailyCarbs,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 10),
                _MacroRow(
                  label: "Protein",
                  value: protein,
                  goal: provider.getDailyProtein,
                  color: const Color(0xFF16A34A),
                ),
                const SizedBox(height: 10),
                _MacroRow(
                  label: "Fat",
                  value: fat,
                  goal: provider.getDailyFat,
                  color: const Color(0xFFF97316),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<Widget> children;
  final bool glass;

  const _ModernSummaryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.children,
    this.glass = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(20);

    final content = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AccentIcon(icon: icon, accent: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ), // titleSmall is intended for short, medium-emphasis text. [web:78]
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ), // labelSmall is a small utilitarian style. [web:80]
                    ),
                  ],
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );

    final base = Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              color: Color(0x14000000),
              offset: Offset(0, 8),
            ),
          ],
        ), // BoxDecoration supports border/shadow/color. [web:4]
        child: content,
      ),
    );

    if (!glass) return base;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _AccentIcon extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _AccentIcon({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.22),
            accent.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, size: 18, color: accent),
    );
  }
}

/// Calories tile: stacked value then label, smaller + cleaner.
class _CalTile extends StatelessWidget {
  final int value;
  final String label;
  final bool emphasize;

  const _CalTile({
    required this.value,
    required this.label,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: emphasize ? const Color(0xFFF8FAFC) : const Color(0xFFFBFBFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: emphasize
              ? cs.outlineVariant.withValues(alpha: 0.55)
              : cs.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${value.round()} kcal",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 12.5, // smaller as requested
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w800,
              height: 1.05,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10, // smaller as requested
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final int value;
  final int goal;
  final Color color;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final safeGoal = goal <= 0 ? 1.0 : goal;
    final progress = (value / safeGoal).clamp(0.0, 1.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ),
            Text(
              "${value.round()}/${goal.round()} g",
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
