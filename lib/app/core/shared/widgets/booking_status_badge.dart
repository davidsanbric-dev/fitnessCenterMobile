import 'package:flutter/material.dart';

/// Pill-shaped booking status badge with subtle per-status colour coding.
///
/// Kept visually consistent with the admin web app's `StatusBadge` component:
/// a tinted background, matching border and a leading dot, using the same
/// status palette (confirmed/pending/cancelled/completed).
class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status, this.placeholder});

  final String? status;
  final String? placeholder;

  static const Color _confirmed = Color(0xFF36A85B);
  static const Color _pending = Color(0xFFD99E2B);
  static const Color _cancelled = Color(0xFFD6504F);
  static const Color _completed = Color(0xFF4A90D9);

  Color _toneFor(String normalized, BuildContext context) {
    switch (normalized) {
      case 'CONFIRMED':
        return _confirmed;
      case 'PENDING':
        return _pending;
      case 'CANCELLED':
      case 'CANCELED':
        return _cancelled;
      case 'COMPLETED':
        return _completed;
      default:
        return Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    }
  }

  String _labelFor(String normalized) {
    if (normalized.isEmpty) {
      return placeholder ?? '—';
    }
    return normalized[0] + normalized.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final normalized = (status ?? '').trim().toUpperCase();
    final color = _toneFor(normalized, context);
    final label = _labelFor(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
