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
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: earned
                ? const Color(0xFFFFF7ED)
                : const Color(0xFFF3F0FF),
            child:
                icon ??
                const Icon(
                  Icons.emoji_events,
                  size: 20,
                  color: Color(0xFF4F39F6),
                ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              name ?? '',
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (earned) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '獲得済み',
                style: TextStyle(color: Color(0xFFB45309), fontSize: 9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
