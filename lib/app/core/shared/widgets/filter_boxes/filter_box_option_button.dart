import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:flutter/material.dart';

class FilterBoxOptionButton extends StatelessWidget {
  const FilterBoxOptionButton({
    super.key,
    required this.label,
    required this.iconData,
    // required this.accentColor,
    required this.onTap,
    this.iconContainerSize = 40,
    this.iconAlignment = Alignment.centerRight,
    this.iconOffset = Offset.zero,
    this.labelStyle,
    this.labelPadding,
  });

  final String label;
  final IconData iconData;
  // final Color accentColor;
  final VoidCallback onTap;
  final double iconContainerSize;
  final Alignment iconAlignment;
  final Offset iconOffset;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? labelPadding;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.2,
        )
        .merge(labelStyle);
    final effectiveLabelPadding =
        labelPadding ??
        EdgeInsets.only(
          right: iconContainerSize + 12,
          bottom: iconContainerSize * 0.5,
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.brandAccentColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: effectiveLabelPadding,
                    child: Text(
                      label,
                      style: textStyle,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                Align(
                  alignment: iconAlignment,
                  child: Transform.translate(
                    offset: iconOffset,
                    child: Container(
                      height: iconContainerSize,
                      width: iconContainerSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Icon(iconData, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
