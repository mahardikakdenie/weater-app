import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  const AvatarWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    String initials = "U";
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = name.substring(0, 1).toUpperCase();
      }
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFF5D5FEF),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
