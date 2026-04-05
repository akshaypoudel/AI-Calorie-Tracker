class Constants {
  static const String API_KEY = "AIzaSyBbMqF7FM8B13ZMgHnokgGgV6XJ6eInJ44";

  static const String BANNER_AD_ID = "ca-app-pub-3940256099942544/6300978111";
  static const String INTERESTIAL_AD_ID =
      "ca-app-pub-3940256099942544/1033173712";
  static const String REWARD_AD_ID = "ca-app-pub-3940256099942544/5224354917";

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
