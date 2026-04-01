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
    return Expanded(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            primaryText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: Colors.black87,
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
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
