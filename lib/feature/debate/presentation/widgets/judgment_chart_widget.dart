import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/judgment_result.dart';

/// 判定グラフWidget（レーダーチャート）
class JudgmentRadarChartWidget extends StatelessWidget {
  final TeamScore proScore;
  final TeamScore conScore;

  const JudgmentRadarChartWidget({
    super.key,
    required this.proScore,
    required this.conScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '5つの評価項目',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.3,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 5,
                ticksTextStyle: const TextStyle(fontSize: 10),
                radarBorderData: const BorderSide(color: Colors.grey, width: 1),
                gridBorderData: const BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
                tickBorderData: const BorderSide(color: Colors.transparent),
                getTitle: (index, angle) {
                  final titles = ['論理性', '根拠', '反論力', '説得力', 'マナー'];
                  return RadarChartTitle(
                    text: titles[index],
                    angle: angle,
                  );
                },
                dataSets: [
                  // 賛成チーム
                  RadarDataSet(
                    fillColor: Colors.blue.withValues(alpha: 0.2),
                    borderColor: Colors.blue,
                    borderWidth: 2,
                    dataEntries: [
                      RadarEntry(value: proScore.logicScore.toDouble()),
                      RadarEntry(value: proScore.evidenceScore.toDouble()),
                      RadarEntry(value: proScore.rebuttalScore.toDouble()),
                      RadarEntry(
                          value: proScore.persuasivenessScore.toDouble()),
                      RadarEntry(value: proScore.mannerScore.toDouble()),
                    ],
                  ),
                  // 反対チーム
                  RadarDataSet(
                    fillColor: Colors.red.withValues(alpha: 0.2),
                    borderColor: Colors.red,
                    borderWidth: 2,
                    dataEntries: [
                      RadarEntry(value: conScore.logicScore.toDouble()),
                      RadarEntry(value: conScore.evidenceScore.toDouble()),
                      RadarEntry(value: conScore.rebuttalScore.toDouble()),
                      RadarEntry(
                          value: conScore.persuasivenessScore.toDouble()),
                      RadarEntry(value: conScore.mannerScore.toDouble()),
                    ],
                  ),
                ],
                titleTextStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  /// 凡例
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('賛成チーム', Colors.blue),
        const SizedBox(width: 24),
        _buildLegendItem('反対チーム', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 判定グラフWidget（棒グラフ）
class JudgmentBarChartWidget extends StatelessWidget {
  final TeamScore proScore;
  final TeamScore conScore;

  const JudgmentBarChartWidget({
    super.key,
    required this.proScore,
    required this.conScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'スコア比較',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = [
                          '論理性',
                          '根拠',
                          '反論力',
                          '説得力',
                          'マナー'
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            titles[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, proScore.logicScore, conScore.logicScore),
                  _makeGroupData(
                      1, proScore.evidenceScore, conScore.evidenceScore),
                  _makeGroupData(
                      2, proScore.rebuttalScore, conScore.rebuttalScore),
                  _makeGroupData(3, proScore.persuasivenessScore,
                      conScore.persuasivenessScore),
                  _makeGroupData(4, proScore.mannerScore, conScore.mannerScore),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, int proValue, int conValue) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: proValue.toDouble(),
          color: Colors.blue,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        BarChartRodData(
          toY: conValue.toDouble(),
          color: Colors.red,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
      barsSpace: 4,
    );
  }

  /// 凡例
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('賛成チーム', Colors.blue),
        const SizedBox(width: 24),
        _buildLegendItem('反対チーム', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
