import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/date_time_cell.dart';
import 'package:flutter/material.dart';

/// Three-line cell that prints date, time and booking status.
class DateTimeStatusCell extends StatelessWidget {
  const DateTimeStatusCell({
    super.key,
    required this.value,
    this.status,
    this.datePlaceholder = '--/--/----',
    this.timePlaceholder = '--:--',
    this.statusPlaceholder = 'Sin estado',
  });

  final DateTime? value;
  final String? status;
  final String datePlaceholder;
  final String timePlaceholder;
  final String statusPlaceholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null;
    final trimmedStatus = status?.trim() ?? '';
    final dateText = hasValue
        ? DateTimeCell.formatDate(value!)
        : datePlaceholder;
    final timeText = hasValue
        ? DateTimeCell.formatTime(value!)
        : timePlaceholder;
    final statusText = trimmedStatus.isEmpty
        ? statusPlaceholder
        : trimmedStatus;

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
        const SizedBox(height: 2),
        Text(
          statusText,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
