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
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
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

  static String formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
