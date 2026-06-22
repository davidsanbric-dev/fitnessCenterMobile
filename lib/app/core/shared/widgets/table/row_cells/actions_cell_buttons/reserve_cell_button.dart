import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ReserveCellButton<T> extends StatelessWidget {
  const ReserveCellButton({super.key, this.slot, this.onReserve});

  factory ReserveCellButton.fromRow({
    Key? key,
    required Map<String, dynamic> row,
    ValueChanged<T>? onReserve,
    String slotKey = 'slot',
  }) {
    return ReserveCellButton<T>(
      key: key,
      slot: row[slotKey] as T?,
      onReserve: onReserve,
    );
  }

  final T? slot;
  final ValueChanged<T>? onReserve;

  @override
  Widget build(BuildContext context) {
    final selectedSlot = slot;
    final handler = onReserve;
    final isDisabled = selectedSlot == null || handler == null;

    return Align(
      child: SizedBox(
        height: 36,
        child: ElevatedButton.icon(
          onPressed: isDisabled ? null : () => handler(selectedSlot),
          icon: const Icon(LucideIcons.calendarCheck, size: 18),
          label: const Text('Book'),
          style: AppTheme.tableActionButtonStyle(),
        ),
      ),
    );
  }
}
