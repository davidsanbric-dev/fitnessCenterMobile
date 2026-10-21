import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Inline error callout shown above a list or form when a load or action fails.
///
/// Uses the same tinted-surface treatment as [BookingStatusBadge] (a
/// translucent tone over the current surface rather than a fixed fill), so it
/// stays legible in both themes instead of painting a light red block behind
/// light text in dark mode.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tone = AppTheme.dangerColor(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Semantics(
        container: true,
        liveRegion: true,
        label: 'Error',
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tone.withValues(alpha: 0.34)),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.alertCircle, color: tone),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: AppTheme.errorMessageEmphasis.copyWith(color: tone),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
