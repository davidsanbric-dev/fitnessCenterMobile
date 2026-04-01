import 'package:flutter/material.dart';

class FilterOption<T> {
  const FilterOption({
    required this.value,
    required this.label,
    this.iconPath,
    this.iconData,
  }) : assert(
         iconPath != null || iconData != null,
         'Provide either iconPath or iconData',
       );

  final T value;
  final String label;
  final String? iconPath;
  final IconData? iconData;
}
