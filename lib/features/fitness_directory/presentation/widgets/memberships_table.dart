import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_body.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class MembershipsTable extends StatelessWidget {
  const MembershipsTable({
    super.key,
    required this.memberships,
    this.isLoading = false,
    this.errorMessage,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.showPagination = false,
  });

  final List<Map<String, dynamic>> memberships;
  final bool isLoading;
  final String? errorMessage;
  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;

  @override
  Widget build(BuildContext context) {
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
      // title: AppLocalizations.of(context).commonPlans,
      icon: LucideIcons.creditCard,
      // headers: const [AppLocalizations.of(context).commonInsurance],
      heightFactor: 0.6,
      margin: const EdgeInsets.only(top: 8),
      body: TableBodySection(
        data: memberships,
        // Stack the plan name over its price and monthly session cap so the
        // catalogue reads like the web admin's plan digest cell.
        fields: const [
          ['name', 'price', 'maxBookings'],
        ],
        isLoading: isLoading,
        errorMessage: errorMessage,
        emptyLabel: AppLocalizations.of(context).emptyNoPlans,
        wrapFields: const {'name', 'price', 'maxBookings'},
        onRowTap: (row) => _showComingSoonSnackBar(
          context,
          row['name']?.toString() ?? 'this membership plan',
        ),
      ),
      pagination: pagination,
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).comingSoonDetail(label)),
        ),
      );
  }
}
