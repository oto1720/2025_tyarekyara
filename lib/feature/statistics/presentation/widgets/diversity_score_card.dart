import 'package:flutter/material.dart';
import '../../models/diversity_score.dart';

class DiversityScoreCardImpl extends StatelessWidget {
  const DiversityScoreCardImpl({super.key, this.diversity});

  final DiversityScore? diversity;

  @override
  Widget build(BuildContext context) {
    final s = diversity?.score ?? 78.0;
    final pct = (s / 100).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_up, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                '視点の多様性スコア',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '様々な立場で考えることで、スコアが上がります',
            style: TextStyle(color: Color(0xFF717182)),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${s.toStringAsFixed(0)} / 100',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: pct,
              color: const Color.fromARGB(255, 0, 0, 0),
              backgroundColor: const Color(0xFFE6E6ED),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'あなたの思考は平均よりも柔軟です 👍',
            style: TextStyle(color: Color(0xFF717182)),
          ),
        ],
      ),
    );
  }
}
