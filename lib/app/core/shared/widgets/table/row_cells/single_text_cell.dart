import 'package:flutter/material.dart';

class CustomDataCell extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final bool allowWrap;

  const CustomDataCell(
    this.text, {
    this.textAlign = TextAlign.center,
    this.allowWrap = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
          fontSize: 13,
        ),
        maxLines: allowWrap ? null : 1,
        overflow: allowWrap ? TextOverflow.visible : TextOverflow.ellipsis,
        softWrap: allowWrap,
        textAlign: textAlign,
      ),
    );
  }
}
