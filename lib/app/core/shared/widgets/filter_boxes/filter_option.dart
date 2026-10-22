import 'package:flutter/material.dart';

class FilterOption<T> {
  const FilterOption({
    this.key,
    required this.value,
    required this.label,
    this.iconPath,
    this.iconData,
  }) : assert(
         iconPath != null || iconData != null,
         'Provide either iconPath or iconData',
       );

  /// Optional key applied to this option's rendered button, so tests and the
  /// end-to-end walkthrough can target an option by meaning rather than by its
  /// position or its (localized) label.
  final Key? key;

  final T value;
  final String label;
  final String? iconPath;
  final IconData? iconData;
}
