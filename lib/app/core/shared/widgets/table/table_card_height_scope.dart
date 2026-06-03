import 'package:flutter/widgets.dart';

/// Makes [TableCard] size its height relative to a bounded parent instead of
/// the full screen.
///
/// By default a [TableCard] resolves its height as
/// `MediaQuery.size.height * heightFactor`, which is correct for full-page
/// listings but overflows when the same table is rendered inside a constrained
/// container such as a dialog. Wrap the subtree in a [TableCardHeightScope]
/// (providing the available bounded height) and every descendant [TableCard]
/// will compute `availableHeight * heightFactor` instead.
class TableCardHeightScope extends InheritedWidget {
  const TableCardHeightScope({
    super.key,
    required this.availableHeight,
    required super.child,
  });

  /// The bounded height the descendant tables should size themselves against.
  final double availableHeight;

  static double? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<TableCardHeightScope>();
    return scope?.availableHeight;
  }

  @override
  bool updateShouldNotify(TableCardHeightScope oldWidget) =>
      oldWidget.availableHeight != availableHeight;
}
