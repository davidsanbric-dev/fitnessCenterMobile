import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';

class TableFiltersSummaryItemData {
  const TableFiltersSummaryItemData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class TableFiltersSummary extends StatelessWidget {
  const TableFiltersSummary({
    super.key,
    required this.items,
    this.itemSpacing = 6,
    this.iconSize = 16,
    this.iconColor,
    this.iconPadding = const EdgeInsets.only(right: 8, top: 2),
    this.labelStyle,
    this.valueStyle,
    this.textStyle,
    this.labelSuffix = ': ',
  });

  static Widget? maybe({
    Key? key,
    required List<TableFiltersSummaryItemData>? items,
    double itemSpacing = 6,
    double iconSize = 16,
    Color? iconColor,
    EdgeInsets iconPadding = const EdgeInsets.only(right: 8, top: 2),
    TextStyle? labelStyle = const TextStyle(fontWeight: FontWeight.w700),
    TextStyle? valueStyle,
    TextStyle? textStyle = const TextStyle(fontSize: 13),
    String labelSuffix = ': ',
  }) {
    if (items == null || items.isEmpty) {
      return null;
    }
    return TableFiltersSummary(
      key: key,
      items: items,
      itemSpacing: itemSpacing,
      iconSize: iconSize,
      iconColor: iconColor,
      iconPadding: iconPadding,
      labelStyle: labelStyle,
      valueStyle: valueStyle,
      textStyle: textStyle,
      labelSuffix: labelSuffix,
    );
  }

  final List<TableFiltersSummaryItemData> items;
  final double itemSpacing;
  final double iconSize;
  final Color? iconColor;
  final EdgeInsets iconPadding;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final TextStyle? textStyle;
  final String labelSuffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedTextStyle = textStyle ?? theme.textTheme.bodyMedium;
    final resolvedLabelStyle =
        labelStyle ?? resolvedTextStyle?.copyWith(color: Colors.grey[600]);
    final resolvedValueStyle = valueStyle ?? resolvedTextStyle;
    final resolvedIconColor = iconColor ?? AppTheme.brandBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => _TableFiltersSummaryItem(
              item: item,
              itemSpacing: itemSpacing,
              iconSize: iconSize,
              iconColor: resolvedIconColor,
              iconPadding: iconPadding,
              textStyle: resolvedTextStyle,
              labelStyle: resolvedLabelStyle,
              valueStyle: resolvedValueStyle,
              labelSuffix: labelSuffix,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _TableFiltersSummaryItem extends StatelessWidget {
  const _TableFiltersSummaryItem({
    required this.item,
    required this.itemSpacing,
    required this.iconSize,
    required this.iconColor,
    required this.iconPadding,
    required this.labelSuffix,
    this.textStyle,
    this.labelStyle,
    this.valueStyle,
  });

  final TableFiltersSummaryItemData item;
  final double itemSpacing;
  final double iconSize;
  final Color iconColor;
  final EdgeInsets iconPadding;
  final String labelSuffix;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: itemSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: iconPadding,
            child: Icon(item.icon, size: iconSize, color: iconColor),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${item.label}$labelSuffix',
                    style: labelStyle,
                  ),
                  TextSpan(text: item.value, style: valueStyle),
                ],
              ),
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
