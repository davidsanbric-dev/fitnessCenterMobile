import 'package:flutter/material.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/header_cell.dart';

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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
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
