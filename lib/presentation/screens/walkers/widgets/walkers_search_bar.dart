import 'package:flutter/material.dart';

class WalkersSearchBar extends StatelessWidget {
  const WalkersSearchBar({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search by name or area...',
          hintStyle: TextStyle(fontSize: 14, color: Color(0xFFB0B8C1)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Color(0xFFB0B8C1),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
