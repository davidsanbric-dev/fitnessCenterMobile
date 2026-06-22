import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Compact icon button that opens a trainer's profile (photo + bio) dialog.
/// Sits beside the "Schedule" availability button in the trainers table.
class TrainerInfoButtonCell extends StatelessWidget {
  const TrainerInfoButtonCell({
    super.key,
    required this.row,
    this.onInfo,
    this.size = 36,
  });

  final Map<String, dynamic> row;
  final ValueChanged<Map<String, dynamic>>? onInfo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final handler = onInfo;
    final accent = AppTheme.brandAccentColor(context);

    return SizedBox(
      height: size,
      width: size,
      child: IconButton(
        onPressed: handler == null ? null : () => handler(row),
        padding: EdgeInsets.zero,
        tooltip: 'View profile',
        icon: Icon(LucideIcons.info, size: 18, color: accent),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: accent),
          ),
        ),
      ),
    );
  }
}
