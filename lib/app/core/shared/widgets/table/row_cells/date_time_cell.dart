import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';

/// Simple two-line cell that prints the date on top and the time below.
class DateTimeCell extends StatelessWidget {
  const DateTimeCell({
    super.key,
    required this.value,
    this.datePlaceholder = '--/--/----',
    this.timePlaceholder = '--:--',
  });

  final DateTime? value;
  final String datePlaceholder;
  final String timePlaceholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null;
    final dateText = hasValue ? formatDate(value!) : datePlaceholder;
    final timeText = hasValue ? formatTime(value!) : timePlaceholder;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dateText,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          timeText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.mutedTextColor(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static String formatDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }

  /// 12-hour clock with AM/PM, matching the admin web app's time format
  /// (Intl `hour: '2-digit', minute: '2-digit', hour12: true`).
  static String formatTime(DateTime value) {
    final local = value.toLocal();
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final hour = hour12.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
