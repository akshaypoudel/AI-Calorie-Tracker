import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static final String API_KEY = dotenv.env['API_KEY'] ?? '';

  static final String BANNER_AD_ID = dotenv.env['BANNER_AD_ID'] ?? '';
  static final String INTERESTIAL_AD_ID = dotenv.env['INTERESTIAL_AD_ID'] ?? '';
  static final String REWARD_AD_ID = dotenv.env['REWARD_AD_ID'] ?? '';

  static double _dailyCalories = 2100;
  static double _dailyFat = 60;
  static double _dialyProtein = 120;
  static double _dailyCarbs = 250;
  static double _targetWeight = 85;

  static void setTargetWeight(double weight) => _targetWeight = weight;
  static double getTargetWeight() => _targetWeight;

  static void setDailyCalories(double calories) => _dailyCalories = calories;
  static double getDailyCalories() => _dailyCalories;

  static void setDailyFat(double fat) => _dailyFat = fat;
  static double getDailyFat() => _dailyFat;

  static void setDailyProtein(double protien) => _dialyProtein = protien;
  static double getDailyProtein() => _dialyProtein;

  static void setDailyCarbs(double carbs) => _dailyCarbs = carbs;
  static double getDailyCarbs() => _dailyCarbs;
}
