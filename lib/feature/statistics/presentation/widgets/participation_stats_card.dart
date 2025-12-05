import 'package:flutter/material.dart';

class ParticipationStatsCardImpl extends StatelessWidget {
  const ParticipationStatsCardImpl({
    super.key,
    this.title = '',
    this.value = '',
    this.accentColor = const Color(0xFF4F39F6),
  });

  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: accentColor, fontSize: 13)),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF0F172B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
