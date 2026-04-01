import 'package:flutter/material.dart';

class TableToolbar extends StatelessWidget {
  const TableToolbar({
    super.key,
    this.filters,
    this.padding = EdgeInsets.zero,
    this.spacing = 12,
    this.runSpacing = 8,
    this.crossAxisAlignment = WrapCrossAlignment.center,
    this.alignment = WrapAlignment.start,
  });

  final List<Widget>? filters;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final WrapAlignment alignment;

  List<Widget> get _filters => filters ?? const [];
  bool get _hasFilters => _filters.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasFilters) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        crossAxisAlignment: crossAxisAlignment,
        alignment: alignment,
        children: _filters,
      ),
    );
  }
}
