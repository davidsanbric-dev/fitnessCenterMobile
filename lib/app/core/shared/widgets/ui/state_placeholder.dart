import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Centred placeholder for the non-content states of a list or table: nothing
/// to show, or a load that failed.
///
/// Both states used to render as a bare centred [Text], which gave a failed
/// load the same visual weight as an empty inbox and offered no way back other
/// than pull-to-refresh. This gives each an icon, a readable tone and, for
/// failures, an explicit retry.
class StatePlaceholder extends StatelessWidget {
  const StatePlaceholder._({
    super.key,
    required this.icon,
    required this.message,
    required this.isError,
    this.onRetry,
    this.retryLabel,
    this.action,
  });

  /// Nothing to show yet. [action] can offer the obvious next step, e.g. a
  /// "book a session" button on an empty bookings list.
  const StatePlaceholder.empty({
    Key? key,
    required String message,
    IconData icon = LucideIcons.calendarX,
    Widget? action,
  }) : this._(
         key: key,
         icon: icon,
         message: message,
         isError: false,
         action: action,
       );

  /// A load failed. [onRetry] renders a retry button when provided.
  const StatePlaceholder.error({
    Key? key,
    required String message,
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
  }) : this._(
         key: key,
         icon: LucideIcons.alertCircle,
         message: message,
         isError: true,
         onRetry: onRetry,
         retryLabel: retryLabel,
       );

  final IconData icon;
  final String message;
  final bool isError;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tone = isError
        ? AppTheme.dangerColor(context)
        : AppTheme.mutedTextColor(context);

    return Semantics(
      container: true,
      liveRegion: isError,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: tone),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tone),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: Text(retryLabel ?? 'Retry'),
                ),
              ],
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}
