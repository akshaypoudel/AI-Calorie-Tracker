import 'package:flutter/material.dart';

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
                  _drawerItem(Icons.flag_outlined, "Daily Goals"),
                  _drawerItem(Icons.monitor_weight_outlined, "Weight Tracker"),
                  _drawerItem(Icons.water_drop_outlined, "Water Tracker"),
                  const SizedBox(height: 20),
                  _drawerItem(Icons.privacy_tip_outlined, "Terms & Privacy"),
                  _drawerItem(Icons.settings_outlined, "Settings"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Reusable Drawer Tile (important for scaling)
  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, size: 24, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        // TODO: Handle navigation
      },
    );
  }
}
