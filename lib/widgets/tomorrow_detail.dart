import 'package:flutter/material.dart';

class TomorrowDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const TomorrowDetail({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
