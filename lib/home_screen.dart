import 'package:ai_calorie_counter/Components/app_drawer.dart';
import 'package:ai_calorie_counter/Components/daily_summary_card.dart';
import 'package:ai_calorie_counter/Components/food_log_card.dart';
import 'package:ai_calorie_counter/Components/bottom_input_bar.dart';
import 'package:ai_calorie_counter/Components/water_card.dart';
import 'package:ai_calorie_counter/constants.dart';
import 'package:ai_calorie_counter/models/ai_log_entry.dart';
import 'package:ai_calorie_counter/repository/app_repository.dart';
import 'package:ai_calorie_counter/screens/weight_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.adSize = AdSize.banner});
  final AdSize adSize;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AILogEntry> aiEntries = [];
  AppRepository repo = AppRepository();
  DateTime selectedDate = DateTime.now();
  BannerAd? _bannerAd;
  late Map<String, int> totalMacros;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    _loadBannerAd();
    await _loadMeals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      _loadDailyGoalsData();
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadDailyGoalsData() async {
    final provider = Provider.of<Constants>(context, listen: false);
    final repo = AppRepository();

    final calories = await repo.getAppData("daily_calories");
    final carbs = await repo.getAppData("daily_carbs");
    final protein = await repo.getAppData("daily_protein");
    final fat = await repo.getAppData("daily_fat");
    final carbPercentage = await repo.getAppData("carbs_percentage");
    final proteinPercentage = await repo.getAppData("protein_percentage");
    final fatPercentage = await repo.getAppData("fat_percentage");

    if (calories != null) {
      provider.setDailyCalories(int.parse(calories));
    }

    if (carbs != null) {
      provider.setDailyCarbs(int.parse(carbs));
    }

    if (protein != null) {
      provider.setDailyProtein(int.parse(protein));
    }

    if (fat != null) {
      provider.setDailyFat(int.parse(fat));
    }
    if (carbPercentage != null) {
      provider.setDailyCarbsPercentage(int.parse(carbPercentage));
    }
    if (proteinPercentage != null) {
      provider.setDailyProteinPercentage(int.parse(proteinPercentage));
    }
    if (fatPercentage != null) {
      provider.setDailyFatPercentage(int.parse(fatPercentage));
    }
  }

  /// Loads a banner ad.
  void _loadBannerAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: Constants.BANNER_AD_ID,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }

  Future<void> _loadMeals() async {
    final logs = await repo.getMealLogs();
    setState(() => aiEntries = logs);
  }

  Map<String, int> _dailyTotals() {
    int foodCalories = 0;
    int exerciseCalories = 0;
    int carbs = 0;
    int protein = 0;
    int fat = 0;

    for (final entry in entriesForSelectedDay) {
      final data = entry.data;
      final type = data["type"];

      if (type == "meal") {
        final totals = data["totals"] ?? {};

        foodCalories += _toInt(totals["calories"]);
        carbs += _toInt(totals["carbs"]);
        protein += _toInt(totals["protein"]);
        fat += _toInt(totals["fat"]);
      }
      if (type == "exercise") {
        exerciseCalories += _toInt(data["calories_burned"]);
      }
    }
    return {
      "foodCalories": foodCalories,
      "exerciseCalories": exerciseCalories,
      "carbs": carbs,
      "protein": protein,
      "fat": fat,
    };
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  List<AILogEntry> get entriesForSelectedDay {
    return aiEntries.where((e) {
      return e.time.year == selectedDate.year &&
          e.time.month == selectedDate.month &&
          e.time.day == selectedDate.day;
    }).toList();
  }

  bool get _isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  String formatHeaderDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }

    return formatPrettyDate(date);
  }

  Future<void> _openCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // prevents future dates
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatPrettyDate(DateTime date) {
    String ordinal(int day) {
      if (day >= 11 && day <= 13) return "${day}th";
      switch (day % 10) {
        case 1:
          return "${day}st";
        case 2:
          return "${day}nd";
        case 3:
          return "${day}rd";
        default:
          return "${day}th";
      }
    }

    return "${ordinal(date.day)} ${DateFormat("MMM").format(date)}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    totalMacros = _dailyTotals();
    final calorieProvider = Provider.of<Constants>(context, listen: true);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.subtract(
                        const Duration(days: 1),
                      );
                    });
                  },
                ),
                GestureDetector(
                  onTap: () => _openCalendar(),
                  child: Text(
                    formatHeaderDate(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: _isToday ? Colors.grey.shade300 : Colors.black,
                  ),
                  onPressed: () {
                    if (!_isToday) {
                      setState(() {
                        selectedDate = selectedDate.add(
                          const Duration(days: 1),
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => WeightTrackerScreen());
            },
            icon: Icon(Icons.fitness_center_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    DailySummaryCard(
                      food: totalMacros["foodCalories"]!,
                      carbs: totalMacros["carbs"]!,
                      protein: totalMacros['protein']!,
                      fat: totalMacros['fat']!,
                      exercise: totalMacros["exerciseCalories"]!,
                      remaining:
                          calorieProvider.getDailyCalories -
                          totalMacros["foodCalories"]! +
                          totalMacros["exerciseCalories"]!,
                    ),

                    const SizedBox(height: 5),
                    WaterCard(selectedDate: selectedDate),
                    const SizedBox(height: 5),
                    ...entriesForSelectedDay.map((e) => FoodLogCard(entry: e)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              BottomInputBar(
                onResult: (input, result) async {
                  final entry = AILogEntry(
                    title: input,
                    time: DateTime.now(),
                    data: result,
                  );

                  await repo.saveMealLog(entry);

                  setState(() {
                    aiEntries.insert(0, entry);
                  });
                },
              ),
              if (_bannerAd != null)
                SizedBox(
                  height: widget.adSize.height.toDouble(),
                  width: double.infinity,
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
