import 'package:ai_calorie_counter/services/ai_food_service.dart';
import 'package:flutter/material.dart';

class BottomInputBar extends StatefulWidget {
  final Function(String input, Map<String, dynamic> result) onResult;
  const BottomInputBar({super.key, required this.onResult});

  @override
  State<BottomInputBar> createState() => BottomInputBarState();
}

class BottomInputBarState extends State<BottomInputBar> {
  final TextEditingController _inputController = TextEditingController();
  String result = "";
  bool loading = false;

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.unfocus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_inputController.text.isEmpty) return;

    setState(() => loading = true);
    _inputController.clear();

    final Map<String, dynamic> result = await AIFoodService.analyzeFood(
      _inputController.text,
    );

    widget.onResult(_inputController.text, result);

    // _inputController.clear();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (result.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(result, style: TextStyle(color: Colors.grey.shade700)),
          ),

        Container(
          margin: const EdgeInsets.only(bottom: 7, top: 3),
          padding: const EdgeInsets.only(left: 15),
          height: 50,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 251, 246),
            borderRadius: BorderRadius.circular(30),

            // subtle border instead of shadow
            border: Border.all(
              color: Colors.orange.withOpacity(0.25),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  focusNode: focusNode,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "What did you eat or exercise?",
                    hintStyle: TextStyle(color: Colors.orange.shade300),
                    border: InputBorder.none,
                  ),
                ),
              ),

              IconButton(
                icon: loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orange.shade400,
                        ),
                      )
                    : Icon(Icons.send_rounded, color: Colors.orange.shade600),
                onPressed: loading ? null : _send,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
