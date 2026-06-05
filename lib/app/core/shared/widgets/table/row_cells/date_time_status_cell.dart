import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/booking_status_badge.dart';
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
        const SizedBox(height: 6),
        BookingStatusBadge(
          status: trimmedStatus,
          placeholder: statusPlaceholder,
        ),
      ],
    );
  }
}
