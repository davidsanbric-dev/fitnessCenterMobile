import 'package:flutter/material.dart';
// import '../../config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/double_text_cell.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/single_text_cell.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/actions_cell_dropdown.dart';

typedef TableCellBuilder = Widget Function(Map<String, dynamic> row);

class TableBody extends StatelessWidget {
  /// List of data rows to render. Each element is a Map (row).
  final List<Map<String, dynamic>> data;

  /// Keys that determine which fields are shown.
  /// Example: ['name', 'rut', 'rol'],
  /// [['name', 'email'], 'rut', 'rol'] or
  /// [(row) => CustomWidget(row), 'rut', 'rol'] to inject a custom cell.
  final List<dynamic> fields;

  /// Map of possible actions (e.g., {'onEdit': fn, 'onDelete': fn})
  final Map<String, void Function(Map<String, dynamic> item)>? actions;

  /// Scroll controller (optional).
  final ScrollController? scrollController;

  /// Vertical spacing between rows.
  final double rowSpacing;

  /// Optional callback when tapping a row.
  final void Function(Map<String, dynamic> row)? onRowTap;

  /// Field keys that should wrap onto multiple lines.
  final Set<String> wrapFields;

  const TableBody({
    super.key,
    required this.data,
    required this.fields,
    this.actions,
    this.scrollController,
    this.rowSpacing = 4.0,
    this.onRowTap,
    this.wrapFields = const <String>{},
  });

  @override
  Widget build(BuildContext context) {
    final alignSingleColumnToStart = fields.length == 1 && actions == null;
    final textAlign = alignSingleColumnToStart
        ? TextAlign.start
        : TextAlign.center;
    final crossAxisAlignment = alignSingleColumnToStart
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4),
      primary: false,
      controller: scrollController,
      itemCount: data.length,
      itemBuilder: (context, index) {
        final row = data[index];
        final rowIdentity = _resolveRowIdentity(row, index);
        final normalizedStatus = _normalizeBookingStatus(
          row['bookingStatus'] ?? row['state'],
        );
        final canConfirmReservation =
            normalizedStatus == 'RESERVADA' || normalizedStatus == 'ANULADA';
        final canCancelReservation =
            normalizedStatus == 'RESERVADA' || normalizedStatus == 'CONFIRMADA';

        return GestureDetector(
          key: ValueKey(rowIdentity),
          onTap: onRowTap != null ? () => onRowTap!(row) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            margin: EdgeInsets.only(bottom: rowSpacing),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: alignSingleColumnToStart
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceBetween,
              children: [
                // Dynamic mapping of columns according to fields
                ...fields.map((field) {
                  if (field is TableCellBuilder) {
                    return Expanded(child: field(row));
                  } else if (field is List && field.length == 2) {
                    final primaryKey = field[0];
                    final secondaryKey = field[1];
                    // Render DualDataCell
                    return DualDataCell(
                      primaryText: row[primaryKey]?.toString() ?? '',
                      secondaryText: row[secondaryKey]?.toString() ?? '',
                      textAlign: textAlign,
                      crossAxisAlignment: crossAxisAlignment,
                      allowPrimaryWrap:
                          primaryKey is String &&
                          wrapFields.contains(primaryKey),
                      allowSecondaryWrap:
                          secondaryKey is String &&
                          wrapFields.contains(secondaryKey),
                    );
                  } else if (field is String) {
                    // Render CustomDataCell
                    return CustomDataCell(
                      row[field]?.toString() ?? '',
                      textAlign: textAlign,
                      allowWrap: wrapFields.contains(field),
                    );
                  } else {
                    throw Exception(
                      'Formato de campo no soportado en TableBody: $field',
                    );
                  }
                }),

                // Dynamic rendering of actions
                if (actions != null)
                  ActionsDropdown(
                    key: ValueKey('$rowIdentity-actions-$normalizedStatus'),
                    onViewFile: actions!['onViewFile'] != null
                        ? () => actions!['onViewFile']!(row)
                        : null,
                    onViewDerivation: actions!['onViewDerivation'] != null
                        ? () => actions!['onViewDerivation']!(row)
                        : null,
                    onView: actions!['onView'] != null
                        ? () => actions!['onView']!(row)
                        : null,
                    onConfirmReservation:
                        canConfirmReservation &&
                            actions!['onConfirmReservation'] != null
                        ? () => actions!['onConfirmReservation']!(row)
                        : null,
                    onCancelReservation:
                        canCancelReservation &&
                            actions!['onCancelReservation'] != null
                        ? () => actions!['onCancelReservation']!(row)
                        : null,
                    onEdit: actions!['onEdit'] != null
                        ? () => actions!['onEdit']!(row)
                        : null,
                    onDelete: actions!['onDelete'] != null
                        ? () => actions!['onDelete']!(row)
                        : null,
                    onAssignRole: actions!['onAssignRole'] != null
                        ? () => actions!['onAssignRole']!(row)
                        : null,
                    onAssignPermission: actions!['onAssignPermission'] != null
                        ? () => actions!['onAssignPermission']!(row)
                        : null,
                    onRemovePermission: actions!['onRemovePermission'] != null
                        ? () => actions!['onRemovePermission']!(row)
                        : null,
                    onUpdateBookingStatus:
                        actions!['onUpdateBookingStatus'] != null
                        ? () => actions!['onUpdateBookingStatus']!(row)
                        : null,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _normalizeBookingStatus(dynamic value) {
    return value?.toString().trim().toUpperCase() ?? '';
  }

  String _resolveRowIdentity(Map<String, dynamic> row, int index) {
    final bookingId = row['bookingId']?.toString().trim() ?? '';
    if (bookingId.isNotEmpty) {
      return bookingId;
    }
    final id = row['id']?.toString().trim() ?? '';
    if (id.isNotEmpty) {
      return id;
    }
    return 'row-$index';
  }
}

/// Helper widget that wraps [TableBody] with loading, error and empty states.
class TableBodySection extends StatelessWidget {
  const TableBodySection({
    super.key,
    required this.data,
    required this.fields,
    this.actions,
    this.scrollController,
    this.rowSpacing = 4.0,
    this.isLoading = false,
    this.errorMessage,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyLabel = 'No hay registros disponibles.',
    this.tableWrapperBuilder,
    this.onRowTap,
    this.wrapFields = const <String>{},
  });

  final List<Map<String, dynamic>> data;
  final List<dynamic> fields;
  final Map<String, void Function(Map<String, dynamic>)>? actions;
  final ScrollController? scrollController;
  final double rowSpacing;
  final Set<String> wrapFields;

  final bool isLoading;
  final String? errorMessage;

  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, String message)? errorBuilder;
  final String emptyLabel;
  final Widget Function(BuildContext context, Widget tableWidget)?
  tableWrapperBuilder;
  final void Function(Map<String, dynamic> row)? onRowTap;

  Widget _defaultLoadingBuilder(BuildContext context) {
    return const Expanded(child: Center(child: CircularProgressIndicator()));
  }

  Widget _defaultErrorBuilder(BuildContext context, String message) {
    return Expanded(
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }

  Widget _defaultTableWrapper(BuildContext context, Widget table) {
    return Expanded(child: table);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return (loadingBuilder ?? _defaultLoadingBuilder).call(context);
    }

    final trimmedError = errorMessage?.trim();
    if (trimmedError != null && trimmedError.isNotEmpty) {
      return (errorBuilder ?? _defaultErrorBuilder).call(context, trimmedError);
    }

    if (data.isEmpty) {
      return Expanded(
        child: Center(child: Text(emptyLabel, textAlign: TextAlign.center)),
      );
    }

    final table = TableBody(
      data: data,
      fields: fields,
      actions: actions,
      scrollController: scrollController,
      rowSpacing: rowSpacing,
      onRowTap: onRowTap,
      wrapFields: wrapFields,
    );

    return (tableWrapperBuilder ?? _defaultTableWrapper).call(context, table);
  }
}
