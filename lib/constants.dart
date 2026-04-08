import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static final String API_KEY = dotenv.env['API_KEY'] ?? '';
  static final String API_KEY2 = dotenv.env['API_KEY2'] ?? '';

  static final String BANNER_AD_ID = dotenv.env['BANNER_AD_ID'] ?? '';
  static final String INTERESTIAL_AD_ID = dotenv.env['INTERESTIAL_AD_ID'] ?? '';
  static final String REWARD_AD_ID = dotenv.env['REWARD_AD_ID'] ?? '';

  static int _dailyCalories = 2100;
  static int _dailyFat = 60;
  static int _dialyProtein = 120;
  static int _dailyCarbs = 250;

  static int _dailyCarbsPercentage = 50;
  static int _dailyProteinPercentage = 25;
  static int _dailyFatPercentage = 25;

  static double _targetWeight = 85;

  static void setTargetWeight(double weight) => _targetWeight = weight;
  static double getTargetWeight() => _targetWeight;

  static void setDailyCalories(int calories) => _dailyCalories = calories;
  static int getDailyCalories() => _dailyCalories;

  static void setDailyFat(int fat) => _dailyFat = fat;
  static int getDailyFat() => _dailyFat;

  static void setDailyProtein(int protien) => _dialyProtein = protien;
  static int getDailyProtein() => _dialyProtein;

  static void setDailyCarbs(int carbs) => _dailyCarbs = carbs;
  static int getDailyCarbs() => _dailyCarbs;

  static void setDailyCarbsPercentage(int percentage) =>
      _dailyCarbsPercentage = percentage;
  static int getDailyCarbsPercentage() => _dailyCarbsPercentage;

  static void setDailyProteinPercentage(int percentage) =>
      _dailyProteinPercentage = percentage;
  static int getDailyProteinPercentage() => _dailyProteinPercentage;

  static void setDailyFatPercentage(int percentage) =>
      _dailyFatPercentage = percentage;
  static int getDailyFatPercentage() => _dailyFatPercentage;
}
