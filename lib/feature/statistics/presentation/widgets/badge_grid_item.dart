import 'package:flutter/material.dart';

class BadgeGridItemImpl extends StatelessWidget {
  const BadgeGridItemImpl({
    super.key,
    this.icon,
    this.name,
    this.earned = false,
  });

  final Widget? icon;
  final String? name;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: earned ? const Color(0xFFFFFBEB) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: earned ? const Color(0xFFFDE68A) : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: earned
                ? const Color(0xFFFFF7ED)
                : const Color(0xFFF3F0FF),
            child:
                icon ??
                const Icon(Icons.emoji_events, color: Color(0xFF4F39F6)),
          ),
          const SizedBox(height: 8),
          Text(
            name ?? '',
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (earned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '獲得済み',
                style: TextStyle(color: Color(0xFFB45309), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
