import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeviceButton extends StatefulWidget {
  final String label;
  final bool state;
  final VoidCallback onTap;
  final IconData icon;
  final Color activeColor;
  final bool isFan;

  const DeviceButton({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
    this.icon = Icons.circle,
    this.activeColor = Colors.green,
    this.isFan = false,
  });

  @override
  State<DeviceButton> createState() => _DeviceButtonState();
}

class _DeviceButtonState extends State<DeviceButton> with TickerProviderStateMixin {
  late AnimationController fanController;

  @override
  void initState() {
    super.initState();
    if (widget.isFan) {
      fanController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      );
      if (widget.state) fanController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant DeviceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFan) {
      if (widget.state) {
        fanController.repeat();
      } else {
        fanController.stop();
        fanController.reset();
      }
    }
  }

  @override
  void dispose() {
    if (widget.isFan) fanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF161b22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
            widget.isFan
                ? RotationTransition(
              turns: fanController,
              child: Icon(
                widget.icon,
                size: 30,
                color: widget.state ? widget.activeColor : Colors.grey,
              ),
            )
                : Icon(
              widget.icon,
              size: 30,
              color: widget.state ? widget.activeColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
