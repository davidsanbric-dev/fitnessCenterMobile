import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CheckAvailabilityButtonCell extends StatelessWidget {
  const CheckAvailabilityButtonCell({
    super.key,
    required this.row,
    this.onCheckAvailability,
    this.label = 'Schedule',
    this.height = 36,
  });

  final Map<String, dynamic> row;
  final ValueChanged<Map<String, dynamic>>? onCheckAvailability;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final handler = onCheckAvailability;
    final isDisabled = handler == null;

    return Align(
      child: SizedBox(
        height: height,
        child: ElevatedButton.icon(
          onPressed: isDisabled
              ? null
              : () {
                  final callback = handler;
                  callback(row);
                },
          icon: const Icon(LucideIcons.calendarCheck, size: 18),
          label: Text(label),
          style: AppTheme.tableActionButtonStyle(),
        ),
      ),
    );
  }
}
