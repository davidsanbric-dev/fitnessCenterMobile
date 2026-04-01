import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:flutter/material.dart';

/// Centralized wrapper around [showDateRangePicker] that applies the project
/// theme and handles invoking the provided callbacks when the user confirms
/// changes to the selected range.
Future<DateTimeRange?> showDateRangePickerDialog({
  required BuildContext context,
  required DateTime selectedStartDate,
  required DateTime selectedEndDate,
  Future<void> Function(DateTime date)? onStartDateChanged,
  Future<void> Function(DateTime date)? onEndDateChanged,
  DateTime? firstDate,
  DateTime? lastDate,
  String helpText = 'Selecciona el rango de fechas',
  String confirmText = 'Guardar',
  String saveText = 'Guardar',
}) async {
  final normalizedEnd = selectedEndDate.isBefore(selectedStartDate)
      ? selectedStartDate
      : selectedEndDate;

  final result = await showDateRangePicker(
    context: context,
    initialDateRange: DateTimeRange(
      start: selectedStartDate,
      end: normalizedEnd,
    ),
    firstDate: firstDate ?? DateTime(2020),
    lastDate: lastDate ?? DateTime(2100, 12, 31),
    helpText: helpText,
    confirmText: confirmText,
    saveText: saveText,
    builder: (pickerContext, child) {
      return Theme(
        data: AppTheme.dateRangePickerTheme(Theme.of(pickerContext)),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );

  if (result != null) {
    if (onStartDateChanged != null && result.start != selectedStartDate) {
      await onStartDateChanged(result.start);
    }
    if (onEndDateChanged != null && result.end != selectedEndDate) {
      await onEndDateChanged(result.end);
    }
  }

  return result;
}

typedef DateRangeLabelBuilder = String Function(DateTime start, DateTime end);

/// Read-only text field that opens the shared date range picker dialog and
/// displays the currently selected range.
class DateRangePickerField extends StatelessWidget {
  const DateRangePickerField({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    this.onStartDateChanged,
    this.onEndDateChanged,
    this.isLoading = false,
    this.width = 320,
    this.labelText = 'Rango',
    this.firstDate,
    this.lastDate,
    this.helpText,
    this.confirmText,
    this.saveText,
    this.decoration,
    this.dateLabelBuilder,
  });

  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final Future<void> Function(DateTime date)? onStartDateChanged;
  final Future<void> Function(DateTime date)? onEndDateChanged;
  final bool isLoading;
  final double width;
  final String labelText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? helpText;
  final String? confirmText;
  final String? saveText;
  final InputDecoration? decoration;
  final DateRangeLabelBuilder? dateLabelBuilder;

  static const String _defaultHelpText = 'Selecciona el rango de fechas';
  static const String _defaultConfirmText = 'Guardar';
  static const String _defaultSaveText = 'Guardar';

  @override
  Widget build(BuildContext context) {
    final isDisabled =
        isLoading || onStartDateChanged == null || onEndDateChanged == null;
    final rangeLabel =
        dateLabelBuilder?.call(selectedStartDate, selectedEndDate) ??
        _defaultLabel(selectedStartDate, selectedEndDate);

    Future<void> openPicker() async {
      await showDateRangePickerDialog(
        context: context,
        selectedStartDate: selectedStartDate,
        selectedEndDate: selectedEndDate,
        onStartDateChanged: onStartDateChanged,
        onEndDateChanged: onEndDateChanged,
        firstDate: firstDate,
        lastDate: lastDate,
        helpText: helpText ?? _defaultHelpText,
        confirmText: confirmText ?? _defaultConfirmText,
        saveText: saveText ?? _defaultSaveText,
      );
    }

    return SizedBox(
      width: width,
      child: TextFormField(
        key: ValueKey(rangeLabel),
        readOnly: true,
        initialValue: rangeLabel,
        decoration:
            decoration ??
            InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.date_range_outlined),
            ),
        onTap: isDisabled ? null : openPicker,
      ),
    );
  }

  static String _defaultLabel(DateTime start, DateTime end) {
    return '${formatDateSlash(start)} – ${formatDateSlash(end)}';
  }
}
