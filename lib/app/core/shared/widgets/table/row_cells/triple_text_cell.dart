import 'package:flutter/material.dart';

/// A cell that stacks up to three lines: a bold primary line and two muted
/// supporting lines. Empty supporting lines are omitted so rows stay compact
/// (e.g. a trainer with no club assigned).
class TripleDataCell extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  final String tertiaryText;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final bool allowPrimaryWrap;
  final bool allowSecondaryWrap;
  final bool allowTertiaryWrap;

  const TripleDataCell({
    required this.primaryText,
    required this.secondaryText,
    required this.tertiaryText,
    this.textAlign = TextAlign.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.allowPrimaryWrap = false,
    this.allowSecondaryWrap = false,
    this.allowTertiaryWrap = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final mutedStyle = TextStyle(
      fontSize: 12,
      color: onSurface.withValues(alpha: 0.65),
    );

    Widget muted(String text, bool allowWrap) {
      return Text(
        text,
        style: mutedStyle,
        maxLines: allowWrap ? null : 1,
        overflow: allowWrap ? TextOverflow.visible : TextOverflow.ellipsis,
        softWrap: allowWrap,
        textAlign: textAlign,
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            primaryText,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: onSurface,
            ),
            maxLines: allowPrimaryWrap ? null : 1,
            overflow: allowPrimaryWrap
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            softWrap: allowPrimaryWrap,
            textAlign: textAlign,
          ),
          if (secondaryText.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            muted(secondaryText, allowSecondaryWrap),
          ],
          if (tertiaryText.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            muted(tertiaryText, allowTertiaryWrap),
          ],
        ],
      ),
    );
  }
}
