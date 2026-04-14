import 'package:ai_calorie_counter/constants.dart';
import 'package:ai_calorie_counter/repository/app_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({super.key});

  @override
  State<DailyGoalsScreen> createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen> {
  int calories = 0;
  late int carbsValue;
  late int proteinValue;
  late int fatValue;
  late int carbsPercentage;
  late int proteinPercentage;
  late int fatPercentage;
  int carbsCaloriePerGram = 4;
  int fatCaloriePerGram = 9;
  int proteinCalorePerGram = 4;
  AppRepository repo = AppRepository();
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      initializeData();
      _isInit = true;
    }
  }

  void initializeData() {
    final provider = Provider.of<Constants>(context, listen: true);
    calories = provider.getDailyCalories;
    carbsValue = provider.getDailyCarbs;
    proteinValue = provider.getDailyProtein;
    fatValue = provider.getDailyFat;
    carbsPercentage = provider.getDailyCarbsPercentage;
    fatPercentage = provider.getDailyFatPercentage;
    proteinPercentage = provider.getDailyProteinPercentage;
  }

  void _openMacroEditor(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return _MacroBottomSheet(
          carbs: carbsPercentage,
          protein: proteinPercentage,
          fat: fatPercentage,
          onSave: (c, p, f) async {
            setState(() {
              carbsPercentage = c;
              proteinPercentage = p;
              fatPercentage = f;
            });
            await saveDailyGoalsAfterPercentageChange(
              carbsPercentage,
              proteinPercentage,
              fatPercentage,
            );
          },
        );
      },
    );
  }

  Future<void> saveDailyGoalsAfterPercentageChange(
    int carbPercent,
    proteinPercent,
    fatPercent,
  ) async {
    int carbs = ((calories * (carbPercent / 100)) / 4).toInt();
    int protein = ((calories * (proteinPercent / 100)) / 4).toInt();
    int fat = ((calories * (fatPercent / 100)) / 9).toInt();

    await saveDailyGoalsData(carbs, protein, fat);
    await saveDailyGoalsPercentage(carbPercent, proteinPercent, fatPercent);
  }

  Widget _macroTile(String title, int percent, int grams) {
    return InkWell(
      onTap: () => _openMacroEditor(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// 🔥 left indicator
            Container(
              width: 6,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$grams g",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Text(
              "$percent%",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("Daily Goals"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 Calories Card
            GestureDetector(
              onTap: _openCaloriesEditor,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFF3E0), // very light orange
                      const Color(0xFFFFE0B2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Calories",
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$calories",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tap to edit",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),

                    /// 🔥 icon makes it feel alive
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 Macros Section
            _macroTile("Carbohydrates", carbsPercentage, carbsValue),
            _macroTile("Protein", proteinPercentage, proteinValue),
            _macroTile("Fat", fatPercentage, fatValue),
          ],
        ),
      ),
    );
  }

  void _openCaloriesEditor() {
    final controller = TextEditingController(text: calories.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const Text(
                    "Edit Calories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () async {
                      final value = int.tryParse(controller.text);

                      if (value != null) {
                        await _onCaloriesSaved(value);
                      }

                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Input Field
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Calories",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onCaloriesSaved(int value) async {
    setState(() => calories = value);
    // Constants.setDailyCalories(value);
    Provider.of<Constants>(context, listen: false).setDailyCalories(value);

    await saveDailyGoalsAfterCaloriesValueChange(value);
  }

  Future<void> saveDailyGoalsAfterCaloriesValueChange(int calorie) async {
    int carbs = ((calorie * (carbsPercentage / 100)) / carbsCaloriePerGram)
        .toInt();
    int protein = ((calorie * (proteinPercentage / 100)) / proteinCalorePerGram)
        .toInt();
    int fat = ((calorie * (fatPercentage / 100)) / fatCaloriePerGram).toInt();

    await repo.saveAppData("daily_calories", calories.toString());

    await saveDailyGoalsData(carbs, protein, fat);
  }

  Future<void> saveDailyGoalsData(int carbs, int protein, int fat) async {
    setState(() {
      carbsValue = carbs;
      proteinValue = protein;
      fatValue = fat;
    });

    final provider = Provider.of<Constants>(context, listen: false);

    provider.setDailyCarbs(carbs);
    provider.setDailyProtein(protein);
    provider.setDailyFat(fat);
    await repo.saveAppData("daily_carbs", carbs.toString());
    await repo.saveAppData("daily_protein", protein.toString());
    await repo.saveAppData("daily_fat", fat.toString());
  }

  Future<void> saveDailyGoalsPercentage(
    int carbPercent,
    int proteinPercent,
    int fatPercent,
  ) async {
    final provider = Provider.of<Constants>(context, listen: false);

    provider.setDailyCarbsPercentage(carbPercent);
    provider.setDailyProteinPercentage(proteinPercent);
    provider.setDailyFatPercentage(fatPercent);
    await repo.saveAppData("carbs_percentage", carbPercent.toString());
    await repo.saveAppData("protein_percentage", proteinPercent.toString());
    await repo.saveAppData("fat_percentage", fatPercent.toString());
  }
}

/// 🔥 Bottom Sheet
class _MacroBottomSheet extends StatefulWidget {
  final int carbs;
  final int protein;
  final int fat;
  final Function(int, int, int) onSave;

  const _MacroBottomSheet({
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.onSave,
  });

  @override
  State<_MacroBottomSheet> createState() => _MacroBottomSheetState();
}

class _MacroBottomSheetState extends State<_MacroBottomSheet> {
  late int carbs;
  late int protein;
  late int fat;

  @override
  void initState() {
    super.initState();
    carbs = widget.carbs;
    protein = widget.protein;
    fat = widget.fat;
  }

  Widget _slider(String label, int value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label (${value.toInt()}%)",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = carbs + protein + fat;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 16),

            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const Text(
                  "Macronutrients",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    widget.onSave(carbs, protein, fat);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _slider("Carbs", carbs, (v) => setState(() => carbs = v.toInt())),
            _slider(
              "Protein",
              protein,
              (v) => setState(() => protein = v.toInt()),
            ),
            _slider("Fat", fat, (v) => setState(() => fat = v.toInt())),

            const SizedBox(height: 10),

            /// total indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: total == 100
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("% Total"),
                  Text(
                    "$total%",
                    style: TextStyle(
                      color: total == 100 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
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
}
