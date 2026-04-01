import 'dart:math' as math;

import 'package:flutter/material.dart';

class AvailableSlotsDropdownLayout {
  const AvailableSlotsDropdownLayout({
    required this.offset,
    required this.width,
    required this.maxHeight,
  });

  final Offset offset;
  final double width;
  final double maxHeight;
}

AvailableSlotsDropdownLayout resolveAvailableBookingsDropdownLayout({
  required BuildContext context,
  required BoxConstraints constraints,
  required double horizontalPadding,
  required bool shouldShowSheet,
  required GlobalKey activeFieldKey,
}) {
  final stackBox = context.findRenderObject();
  final activeFieldBox = _renderBoxForKey(activeFieldKey);

  Offset dropdownOffset = Offset(horizontalPadding, 0);
  double dropdownWidth = constraints.maxWidth - (horizontalPadding * 2);
  double maxDropdownHeight = 280.0;

  if (stackBox is RenderBox && activeFieldBox != null) {
    final fieldTopLeft = activeFieldBox.localToGlobal(
      Offset.zero,
      ancestor: stackBox,
    );
    final dropdownGap = shouldShowSheet ? 0 : 8.0;
    final dropdownTop =
        fieldTopLeft.dy + activeFieldBox.size.height + dropdownGap;
    dropdownOffset = Offset(fieldTopLeft.dx, dropdownTop);
    dropdownWidth = activeFieldBox.size.width;
    final availableHeight = constraints.maxHeight - dropdownTop;
    maxDropdownHeight = math.min(
      280.0,
      MediaQuery.of(context).size.height * 0.35,
    );
    if (availableHeight > 0) {
      maxDropdownHeight = math.min(maxDropdownHeight, availableHeight);
    }
  }

  return AvailableSlotsDropdownLayout(
    offset: dropdownOffset,
    width: dropdownWidth,
    maxHeight: maxDropdownHeight,
  );
}

RenderBox? _renderBoxForKey(GlobalKey key) {
  final context = key.currentContext;
  final renderObject = context?.findRenderObject();
  if (renderObject is RenderBox && renderObject.hasSize) {
    return renderObject;
  }
  return null;
}
