import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_body.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_card.dart';
import 'package:flutter/material.dart';

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
      // title: 'Membershipes',
      icon: Icons.card_membership,
      // headers: const ['Previsión'],
      heightFactor: 0.6,
      margin: const EdgeInsets.only(top: 8),
      body: TableBodySection(
        data: memberships,
        fields: const ['name'],
        isLoading: isLoading,
        errorMessage: errorMessage,
        emptyLabel: 'No membership plans available.',
        wrapFields: const {'name'},
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
          content: Text(
            'Detailed information for $label will be available soon.',
          ),
        ),
      );
  }
}
