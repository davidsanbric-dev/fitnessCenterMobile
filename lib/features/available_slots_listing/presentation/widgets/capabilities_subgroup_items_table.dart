import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/utils/format/info_card.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_body.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_card.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CapabilitiesSubgroupItemsTable extends StatelessWidget {
  const CapabilitiesSubgroupItemsTable({
    super.key,
    required this.items,
    this.isLoading = false,
    this.errorMessage,
    this.filterSummary,
    this.onItemSelected,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.showPagination = false,
  });

  final List<CapabilityDto> items;
  final bool isLoading;
  final String? errorMessage;
  final List<TableFiltersSummaryItemData>? filterSummary;
  final ValueChanged<CapabilityDto>? onItemSelected;
  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;

  @override
  Widget build(BuildContext context) {
    final showAction = onItemSelected != null;
    final tableRows = _buildRows(context, items);
    final headers = <String>[
      AppLocalizations.of(context).classOption,
      if (showAction) AppLocalizations.of(context).commonAction,
    ];
    final shouldShowPagination =
        showPagination ||
        pageNumber != null ||
        pageSize != null ||
        totalItems != null ||
        onPageChanged != null;
    final pagination = shouldShowPagination
        ? TableCardPaginationConfig(
            pageNumber: pageNumber,
            pageSize: pageSize,
            totalItems: totalItems,
            onPageChanged: onPageChanged,
          )
        : null;

    return TableCard(
      title: AppLocalizations.of(context).classOptions,
      icon: LucideIcons.listChecks,
      headers: headers,
      toolbar: _buildFiltersSummary(),
      heightFactor: 0.7,
      body: TableBodySection(
        data: tableRows,
        fields: [
          'description',
          if (showAction)
            (row) => _SubgroupItemActionsCell(
              row: row,
              onItemSelected: onItemSelected,
            ),
        ],
        isLoading: isLoading,
        errorMessage: errorMessage,
        emptyLabel: AppLocalizations.of(context).emptyNoClassOptions,
        wrapFields: const {'description'},
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      pagination: pagination,
    );
  }

  List<Map<String, dynamic>> _buildRows(
    BuildContext context,
    List<CapabilityDto> source,
  ) {
    return source
        .map(
          (item) => {
            'description': item.description,
            'scheduleType': item.scheduleType.trim().isEmpty
                ? AppLocalizations.of(context).commonNormal
                : item.scheduleType.trim(),
            'item': item,
          },
        )
        .toList(growable: false);
  }

  Widget? _buildFiltersSummary() {
    return TableFiltersSummary.maybe(items: filterSummary);
  }
}

class _SubgroupItemActionsCell extends StatelessWidget {
  const _SubgroupItemActionsCell({
    required this.row,
    required this.onItemSelected,
  });

  final Map<String, dynamic> row;
  final ValueChanged<CapabilityDto>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final item = row['item'];
    if (item is! CapabilityDto) {
      return const SizedBox.shrink();
    }

    return Align(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          SizedBox(
            height: 34,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _showPreparationDialog(context, item.preparation),
              icon: const Icon(LucideIcons.fileText, size: 16),
              label: Text(AppLocalizations.of(context).commonPreparation),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.brandAccentColor(context),
                side: BorderSide(
                  color: AppTheme.brandAccentColor(
                    context,
                  ).withValues(alpha: 0.5),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 34,
            child: ElevatedButton.icon(
              onPressed: onItemSelected == null
                  ? null
                  : () => onItemSelected!(item),
              icon: const Icon(LucideIcons.calendarCheck, size: 16),
              label: Text(AppLocalizations.of(context).commonTimeSlots),
              style: AppTheme.tableActionButtonStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPreparationDialog(
    BuildContext context,
    String preparationContent,
  ) {
    final preparationText = formatHTMLContent(preparationContent);
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          AppLocalizations.of(context).commonPreparation,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
          child: SingleChildScrollView(
            child: SelectableText(
              preparationText.isEmpty
                  ? AppLocalizations.of(context).emptyNoPreparation
                  : preparationText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context).commonClose,
              style: TextStyle(color: AppTheme.brandAccentColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
