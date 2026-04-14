import 'package:ai_calorie_counter/constants.dart';
import 'package:ai_calorie_counter/models/weight_entry.dart';
import 'package:ai_calorie_counter/repository/app_repository.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

BoxDecoration _softCardDecoration({required ColorScheme cs, Color? tint}) {
  final base = tint ?? Colors.white;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [base, base.withValues(alpha: 0.92)],
    ),
    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
    boxShadow: const [
      BoxShadow(
        blurRadius: 18,
        offset: Offset(0, 10),
        color: Color(0x12000000),
      ),
    ],
  ); // BoxDecoration supports gradient/border/shadow. [web:4]
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final tint = Color.lerp(Colors.white, accent, 0.08)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _softCardDecoration(cs: cs, tint: tint),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: accent.withValues(alpha: 0.14),
              border: Border.all(color: accent.withValues(alpha: 0.22)),
            ),
            child: Icon(Icons.monitor_weight_outlined, color: accent, size: 20),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  const _TimeTabs({required this.selectedIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _softCardDecoration(cs: cs, tint: Colors.white),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text("Week")),
          ButtonSegment(value: 1, label: Text("Month")),
          ButtonSegment(value: 2, label: Text("Year")),
        ],
        selected: {selectedIndex},
        onSelectionChanged: (s) => onTabChanged(s.first),
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: cs.onSurface,
          selectedForegroundColor: cs.onPrimary,
          selectedBackgroundColor: cs.primary.withValues(alpha: 0.85),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ), // SegmentedButton is the Material widget for tabs. [web:90]
    );
  }
}

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  double currentWeight = 0;
  List<WeightEntry> entries = [];
  int selectedTabIndex = 0;
  final TextEditingController _weightController = TextEditingController();
  final AppRepository _repo = AppRepository();

  List<WeightEntry> get filteredEntries {
    final result = List<WeightEntry>.from(entries);
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedEntries = await _repo.getAllWeightEntries();
    if (mounted) {
      setState(() {
        entries = loadedEntries;
        currentWeight = entries.isNotEmpty
            ? entries.first.weight
            : currentWeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Weight Tracker",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: _showAddEntryDialog,
            icon: const Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statsRow(cs),
            const SizedBox(height: 18),
            _TimeTabs(
              selectedIndex: selectedTabIndex,
              onTabChanged: (index) => setState(() => selectedTabIndex = index),
            ),
            const SizedBox(height: 18),
            _weightChart(),
            const SizedBox(height: 22),
            Text(
              "Weight Entries",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            ...filteredEntries.map(_weightTile),
          ],
        ),
      ),
    );
  }

  Widget _statsRow(ColorScheme cs) {
    final provider = Provider.of<Constants>(context, listen: true);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showEditWeightDialog(
              currentWeight,
              "Current Weight",
              (newVal) {
                setState(() => currentWeight = newVal);
                _repo.saveAppData('current_weight', newVal.toString());
              },
            ),
            child: _StatCard(
              title: "Current Weight",
              value: "${currentWeight.toStringAsFixed(1)} kg",
              accent: const Color(0xFF2563EB), // soft blue
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: GestureDetector(
            onTap: () => _showEditWeightDialog(
              provider.getTargetWeight,
              "Target Weight",
              (newVal) {
                setState(() => provider.setTargetWeight(newVal));
                _repo.saveAppData('target_weight', newVal.toString());
              },
            ),
            child: _StatCard(
              title: "Target Weight",
              value: "${provider.getTargetWeight.toStringAsFixed(1)} kg",
              accent: const Color(0xFF16A34A), // soft green
            ),
          ),
        ),
      ],
    );
  }

  Widget _weightChart() {
    final provider = Provider.of<Constants>(context, listen: false);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final data = _downsample(entries);

    if (data.isEmpty) {
      return Container(
        height: 270,
        padding: const EdgeInsets.all(16),
        decoration: _softCardDecoration(cs: cs, tint: Colors.white),
        child: Center(
          child: Text(
            "No data for this period",
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    data.sort((a, b) => a.date.compareTo(b.date));

    double roundDownTo10(double v) => (v ~/ 10) * 10;
    double roundUpTo10(double v) => ((v + 9) ~/ 10) * 10;

    final weights = data.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

    final combinedMin = [
      minWeight,
      provider.getTargetWeight,
    ].reduce((a, b) => a < b ? a : b);
    final combinedMax = [
      maxWeight,
      provider.getTargetWeight,
    ].reduce((a, b) => a > b ? a : b);

    final chartMinY = roundDownTo10(combinedMin);
    final chartMaxY = roundUpTo10(combinedMax);

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
        .toList();

    final lineGradient = LinearGradient(
      colors: [
        const Color(0xFF6366F1), // indigo
        const Color(0xFF22C55E), // green
      ],
    );

    return Container(
      height: 270,
      padding: const EdgeInsets.all(16),
      decoration: _softCardDecoration(cs: cs, tint: Colors.white),
      child: LineChart(
        LineChartData(
          minY: chartMinY,
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) => FlLine(
              color: cs.outlineVariant.withValues(alpha: 0.35),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 10,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }

                  int step;
                  if (selectedTabIndex == 0) {
                    step = (data.length / 7).ceil();
                  } else if (selectedTabIndex == 1) {
                    step = (data.length / 6).ceil();
                  } else {
                    step = (data.length / 12).ceil();
                  }
                  if (step <= 0 || index % step != 0) return const SizedBox();

                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _getDateLabel(data[index].date, selectedTabIndex),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            // Weight line (gradient + soft area fill). [web:85]
            LineChartBarData(
              spots: spots,
              isCurved: data.length < 15,
              gradient: lineGradient,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: data.length < 20),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.18),
                    const Color(0xFF22C55E).withValues(alpha: 0.03),
                  ],
                ),
              ),
            ),

            // Target line (dashed feel using transparency + thinner bar).
            LineChartBarData(
              spots: [
                FlSpot(0, provider.getTargetWeight),
                FlSpot((data.length - 1).toDouble(), provider.getTargetWeight),
              ],
              isCurved: false,
              color: const Color(0xFF16A34A),
              barWidth: 2,
              dashArray: const [6, 6],
              dotData: const FlDotData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  if (spot.barIndex != 0) return null;
                  final index = spot.x.toInt();
                  if (index < 0 || index >= data.length) return null;

                  final entry = data[index];

                  return LineTooltipItem(
                    "${entry.weight.toStringAsFixed(1)} kg\n"
                    "${DateFormat("MMM d, yyyy h:mm a").format(entry.date)}",
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<WeightEntry> _downsample(List<WeightEntry> data) {
    if (data.length <= 20) return data;
    final step = (data.length / 20).ceil();
    return [for (int i = 0; i < data.length; i += step) data[i], data.last];
  }

  String _getDateLabel(DateTime date, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return DateFormat("E").format(date);
      case 1:
        return "W${(date.day / 7).ceil()}";
      case 2:
        return DateFormat("MMM").format(date);
      default:
        return DateFormat("M/d").format(date);
    }
  }

  Widget _weightTile(WeightEntry entry) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onLongPress: () => _showEntryOptions(entry),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: _softCardDecoration(cs: cs, tint: const Color(0xFFFFFFFF)),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6366F1), Color(0xFF22C55E)],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${entry.weight.toStringAsFixed(1)} kg",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat("EEEE, MMMM d, yyyy h:mm a").format(entry.date),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddEntryDialog() async {
    _weightController.clear();
    DateTime selectedDateTime = DateTime.now();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true, // modern handle. [web:106]
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> pickDateTime() async {
              final date = await showDatePicker(
                context: ctx,
                initialDate: selectedDateTime,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date == null) return;

              final time = await showTimePicker(
                context: ctx,
                initialTime: TimeOfDay.fromDateTime(selectedDateTime),
              );

              setModalState(() {
                selectedDateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time?.hour ?? selectedDateTime.hour,
                  time?.minute ?? selectedDateTime.minute,
                );
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add weight",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Track your progress with a quick entry.",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Weight (kg)",
                      hintText: "e.g. 74.5",
                      filled: true,
                      fillColor: const Color(0xFFF7F8FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.55),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: cs.primary.withValues(alpha: 0.9),
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: pickDateTime,
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, color: cs.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              DateFormat(
                                "MMM dd, yyyy  •  h:mm a",
                              ).format(selectedDateTime),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.7),
                            ),
                            foregroundColor: cs.onSurface,
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final weight = double.tryParse(
                              _weightController.text,
                            );
                            if (weight == null) return;

                            final entry = WeightEntry(weight, selectedDateTime);
                            await _repo.saveWeightEntry(entry);
                            await _loadData();
                            if (mounted) Navigator.pop(ctx);
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Add"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ); // showModalBottomSheet supports isScrollControlled/useSafeArea/showDragHandle. [web:99][web:102][web:106]
  }

  void _showEditWeightDialog(
    double initialValue,
    String title,
    Function(double) onSave,
  ) {
    final controller = TextEditingController(
      text: initialValue.toStringAsFixed(1),
    );
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.all(18),
        contentPadding: const EdgeInsets.fromLTRB(
          20,
          14,
          20,
          8,
        ), // configurable. [web:113]
        actionsPadding: const EdgeInsets.fromLTRB(
          16,
          6,
          16,
          16,
        ), // configurable. [web:104]
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: "Weight (kg)",
            filled: true,
            fillColor: const Color(0xFFF7F8FC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
        actions: [
          SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.7),
                ),
                foregroundColor: cs.onSurface,
              ),
              child: const Text("Cancel"),
            ),
          ),
          SizedBox(
            height: 46,
            child: FilledButton(
              onPressed: () {
                final newVal = double.tryParse(controller.text) ?? initialValue;
                onSave(newVal);
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }

  void _showEntryOptions(WeightEntry entry) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true, // [web:106]
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(Icons.edit_rounded, color: cs.primary, size: 20),
                ),
                title: Text(
                  "Edit Entry",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  "Update the weight value",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditEntryDialog(entry);
                },
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                title: Text(
                  "Delete Entry",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  "This can’t be undone",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _deleteEntry(entry);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    ); // Modal sheet params: useSafeArea/showDragHandle. [web:99][web:102][web:106]
  }

  void _showEditEntryDialog(WeightEntry entry) {
    final controller = TextEditingController(
      text: entry.weight.toStringAsFixed(1),
    );
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.all(18),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        title: Text(
          "Edit weight",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: "Weight (kg)",
            filled: true,
            fillColor: const Color(0xFFF7F8FC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
          ),
          SizedBox(
            height: 46,
            child: FilledButton(
              onPressed: () async {
                final newWeight = double.tryParse(controller.text);
                if (newWeight != null) {
                  await _repo.updateWeightEntry(entry, newWeight);
                  await _loadData();
                }
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry(WeightEntry entry) async {
    await _repo.deleteWeightEntry(entry);
    await _loadData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }
}
