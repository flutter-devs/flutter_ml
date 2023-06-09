import 'package:flutter/material.dart';
import 'package:flutter_ml_demo/widgets/hover_button.dart';

class AppButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;
  final IconData icon;

  const AppButton(
      {Key? key, required this.onTap, required this.color, required this.icon})
      : super(key: key);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: widget.onTap,
        onTapDown: (e) {
          setState(() {
            isPressed = true;
          });
        },
        onTapUp: (e) {
          setState(() {
            isPressed = false;
          });
        },
        child: Stack(children: [
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.center,
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
              ),
            ],
          ),
          HoverButton(
            isPressed: isPressed,
            child: Container(
              height: 50,
              width: 150,
              decoration: BoxDecoration(
                  color: widget.color, borderRadius: BorderRadius.circular(12)),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ]));
  }
}
