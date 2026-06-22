import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/widgets/memberships_table.dart';
import 'package:flutter/material.dart';

class MembershipsDirectoryPage extends StatelessWidget {
  const MembershipsDirectoryPage({
    super.key,
    required this.memberships,
    required this.isLoading,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MembershipsTable(
            memberships: memberships,
            isLoading: isLoading,
            errorMessage: errorMessage,
            pageNumber: pageNumber,
            pageSize: pageSize,
            totalItems: totalItems,
            onPageChanged: onPageChanged,
            showPagination: showPagination,
          ),
        ],
      ),
    );
  }
}
