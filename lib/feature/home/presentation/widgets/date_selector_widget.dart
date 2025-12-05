import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/daily_topic_provider.dart';

/// 日付選択ウィジェット
class DateSelectorWidget extends ConsumerWidget {
  const DateSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final today = DateTime.now();
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 前の日へ
          _NavigationButton(
            icon: Icons.chevron_left,
            onPressed: () => _goToPreviousDay(ref),
            tooltip: '前の日',
          ),

          // 日付表示（タップでDatePicker表示）
          InkWell(
            onTap: () => _showDatePicker(context, ref),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('M/d (E)', 'ja').format(selectedDate),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),

          // 次の日へ（今日より先には進めない）
          _NavigationButton(
            icon: Icons.chevron_right,
            onPressed: isToday ? null : () => _goToNextDay(ref),
            tooltip: '次の日',
            isDisabled: isToday,
          ),
        ],
      ),
    );
  }

  /// 前の日へ移動
  void _goToPreviousDay(WidgetRef ref) {
    final currentDate = ref.read(selectedDateProvider);
    final previousDay = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day - 1,
    );
    ref.read(selectedDateProvider.notifier).setDate(previousDay);
  }

  /// 次の日へ移動
  void _goToNextDay(WidgetRef ref) {
    final currentDate = ref.read(selectedDateProvider);
    final today = DateTime.now();
    final nextDay = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day + 1,
    );

    // 今日より先には進めない
    if (nextDay.year <= today.year &&
        nextDay.month <= today.month &&
        nextDay.day <= today.day) {
      ref.read(selectedDateProvider.notifier).setDate(nextDay);
    }
  }

  /// DatePickerを表示
  Future<void> _showDatePicker(BuildContext context, WidgetRef ref) async {
    final currentDate = ref.read(selectedDateProvider);
    final today = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: today,
      locale: const Locale('ja', 'JP'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.background,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      ref.read(selectedDateProvider.notifier).setDate(selectedDate);
    }
  }
}

/// ナビゲーションボタン
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool isDisabled;

  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: isDisabled ? AppColors.disabled : AppColors.textPrimary,
        size: 20,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
      splashRadius: 20,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
    );
  }
}
