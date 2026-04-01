import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/header_cell.dart';

class TableHeader extends StatelessWidget {
  final List<String> headers;

  const TableHeader({super.key, required this.headers});

  @override
  Widget build(BuildContext context) {
    if (headers.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.brandBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: headers.map(HeaderCell.new).toList(),
      ),
    );
  }
}
