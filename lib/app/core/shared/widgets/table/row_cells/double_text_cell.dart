import 'package:flutter/material.dart';

class DualDataCell extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final bool allowPrimaryWrap;
  final bool allowSecondaryWrap;

  const DualDataCell({
    required this.primaryText,
    required this.secondaryText,
    this.textAlign = TextAlign.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.allowPrimaryWrap = false,
    this.allowSecondaryWrap = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
          const SizedBox(height: 2),
          Text(
            secondaryText,
            style: TextStyle(
              fontSize: 12,
              color: onSurface.withValues(alpha: 0.65),
            ),
            maxLines: allowSecondaryWrap ? null : 1,
            overflow: allowSecondaryWrap
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            softWrap: allowSecondaryWrap,
            textAlign: textAlign,
          ),
        ],
      ),
    );
  }
}
