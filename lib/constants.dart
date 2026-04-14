import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants extends ChangeNotifier {
  static final String API_KEY = dotenv.env['API_KEY'] ?? '';
  static final String API_KEY2 = dotenv.env['API_KEY2'] ?? '';

  static final String BANNER_AD_ID = dotenv.env['BANNER_AD_ID'] ?? '';
  static final String INTERESTIAL_AD_ID = dotenv.env['INTERESTIAL_AD_ID'] ?? '';
  static final String REWARD_AD_ID = dotenv.env['REWARD_AD_ID'] ?? '';

  int _dailyCalories = 2100;
  int _dailyFat = 60;
  int _dialyProtein = 120;
  int _dailyCarbs = 250;

  int _dailyCarbsPercentage = 50;
  int _dailyProteinPercentage = 25;
  int _dailyFatPercentage = 25;

  double _targetWeight = 85;

  void setTargetWeight(double weight) {
    _targetWeight = weight;
    notifyListeners();
  }

  double get getTargetWeight => _targetWeight;

  void setDailyCalories(int calories) {
    _dailyCalories = calories;
    notifyListeners();
  }

  int get getDailyCalories => _dailyCalories;

  void setDailyFat(int fat) {
    _dailyFat = fat;
    notifyListeners();
  }

  int get getDailyFat => _dailyFat;

  void setDailyProtein(int protien) {
    _dialyProtein = protien;
    notifyListeners();
  }

  int get getDailyProtein => _dialyProtein;

  void setDailyCarbs(int carbs) {
    _dailyCarbs = carbs;
    notifyListeners();
  }

  int get getDailyCarbs => _dailyCarbs;

  void setDailyCarbsPercentage(int percentage) {
    _dailyCarbsPercentage = percentage;
    notifyListeners();
  }

  int get getDailyCarbsPercentage => _dailyCarbsPercentage;

  void setDailyProteinPercentage(int percentage) {
    _dailyProteinPercentage = percentage;
    notifyListeners();
  }

  int get getDailyProteinPercentage => _dailyProteinPercentage;

  void setDailyFatPercentage(int percentage) {
    _dailyFatPercentage = percentage;
    notifyListeners();
  }

  int get getDailyFatPercentage => _dailyFatPercentage;
}
