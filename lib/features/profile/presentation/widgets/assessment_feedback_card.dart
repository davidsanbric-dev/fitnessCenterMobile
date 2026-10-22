import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/app/core/utils/format/date_time.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Expandable card that surfaces a single completed session's trainer feedback.
/// Collapsed: date · discipline/session · trainer. Expanded: the full note text.
class AssessmentFeedbackCard extends StatefulWidget {
  const AssessmentFeedbackCard({
    super.key,
    required this.booking,
    this.initiallyExpanded = false,
  });

  final BookingDto booking;
  final bool initiallyExpanded;

  @override
  State<AssessmentFeedbackCard> createState() => _AssessmentFeedbackCardState();
}

class _AssessmentFeedbackCardState extends State<AssessmentFeedbackCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  String get _sessionLabel {
    final service = widget.booking.serviceName?.trim() ?? '';
    final discipline = widget.booking.disciplineName?.trim() ?? '';
    if (service.isNotEmpty) return service;
    if (discipline.isNotEmpty) return discipline;
    return AppLocalizations.of(context).commonSession;
  }

  String get _trainerLabel {
    final name = widget.booking.trainerName?.trim() ?? '';
    return name.isNotEmpty ? name : AppLocalizations.of(context).commonTrainer;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.brandAccentColor(context);
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.borderSoft;
    final panelColor = isDark ? AppTheme.darkPanel : Colors.white;
    final mutedColor = AppTheme.secondaryTextColor(context);
    final noteText = (widget.booking.notes ?? '').trim();

    // A borderRadius requires a *uniform* border, so the rounded outline uses a
    // single border color and the brand accent is painted as a separate left
    // stripe inside the clip. The previous non-uniform Border (accent left +
    // soft other sides) + borderRadius threw during paint, which silently blanks
    // the whole card in release builds.
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: accent, width: 3)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, mutedColor, accent),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: _buildNoteBody(
                        context,
                        noteText,
                        mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color mutedColor, Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.calendarCheck, size: 13, color: mutedColor),
                  const SizedBox(width: 5),
                  Text(
                    formatDateLabel(widget.booking.schedulingDate),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: mutedColor),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '· $_sessionLabel',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: mutedColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(LucideIcons.dumbbell, size: 13, color: mutedColor),
                  const SizedBox(width: 5),
                  Text(
                    _trainerLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(
          _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
          size: 18,
          color: accent,
        ),
      ],
    );
  }

  Widget _buildNoteBody(
    BuildContext context,
    String noteText,
    Color mutedColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: mutedColor.withValues(alpha: 0.25)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(LucideIcons.messageSquare, size: 13, color: mutedColor),
              const SizedBox(width: 5),
              Text(
                AppLocalizations.of(context).profileTrainerFeedback,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: mutedColor,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            noteText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
