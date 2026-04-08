import 'package:ai_calorie_counter/screens/daily_goals.dart';
import 'package:ai_calorie_counter/screens/settings_screen.dart';
import 'package:ai_calorie_counter/screens/terms_and_privacy_screen.dart';
import 'package:ai_calorie_counter/screens/water_tracker_goal_screen.dart';
import 'package:ai_calorie_counter/screens/weight_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

enum AppDrawerPages {
  dailyGoals("Daily Goals", DailyGoalsScreen()),
  weightTracker("Weight Tracker", WeightTrackerScreen()),
  waterTracker("Water Tracker", WaterTrackerGoalScreen()),
  termsAndPrivacy("Terms & Privacy", TermsAndPrivacyScreen()),
  settings("Settings", SettingsScreen());

  final String name;
  final Widget page;

  const AppDrawerPages(this.name, this.page);
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade100,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.blue, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    "Do It Health Tracker",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade300),

            /// 🔥 MENU ITEMS
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(Icons.flag_outlined, AppDrawerPages.dailyGoals),
                  _drawerItem(
                    Icons.monitor_weight_outlined,
                    AppDrawerPages.weightTracker,
                  ),
                  _drawerItem(
                    Icons.water_drop_outlined,
                    AppDrawerPages.waterTracker,
                  ),
                  const SizedBox(height: 20),
                  _drawerItem(
                    Icons.privacy_tip_outlined,
                    AppDrawerPages.termsAndPrivacy,
                  ),
                  _drawerItem(Icons.settings_outlined, AppDrawerPages.settings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Reusable Drawer Tile (important for scaling)
  Widget _drawerItem(IconData icon, AppDrawerPages transferPage) {
    return ListTile(
      leading: Icon(icon, size: 24, color: Colors.black87),
      title: Text(
        transferPage.name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Get.to(() => transferPage.page);
      },
    );
  }
}
