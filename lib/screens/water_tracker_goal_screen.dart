import 'package:ai_calorie_counter/constants.dart';
import 'package:ai_calorie_counter/repository/app_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  bool isEnabled = true;
  int waterMl = 250;
  AppRepository repo = AppRepository();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    final waterTrackerStatus =
        await repo.getAppData("water_tracker_status") ?? 'true';
    setState(() {
      isEnabled = (waterTrackerStatus == 'true') ? true : false;
    });

    _controller = TextEditingController(
      text: context.read<Constants>().getWaterCups.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Constants>(context, listen: true);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F2), // soft orange background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Water Tracker",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 Enable Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Enable Water Tracker",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Switch(
                    value: isEnabled,
                    activeColor: Colors.orange,
                    onChanged: (val) async {
                      setState(() => isEnabled = val);
                      await changeWaterTrackerStatus(val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 Goal Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFEDE5), const Color(0xFFFFF3E0)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Water Goal",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${((provider.getWaterCups * waterMl) / 1000).toStringAsFixed(0)}L",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Input Row
                  Row(
                    children: [
                      /// Cups input
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _controller,
                            onChanged: (val) {
                              provider.setWaterCups(int.tryParse(val) ?? 8);
                              repo.saveAppData('water_cups', val);
                              setState(() {});
                            },
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        "Cups",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Info text
                  Text(
                    "1 cup ≈ 250 ml",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> changeWaterTrackerStatus(bool val) async {
    final provider = Provider.of<Constants>(context, listen: false);
    provider.setWaterTrackerStatus(val);
    await repo.saveAppData("water_tracker_status", val.toString());
  }
}
