import 'package:flutter/material.dart';

typedef DeleteDialogHandler = Future<String?> Function({required String id});

Future<void> showDeleteDialog({
  required BuildContext context,
  DeleteDialogHandler? onDelete,
  Object? rowId,
  String title = 'Delete item',
  String content = 'Do you want to delete this item?',
  Color? confirmButtonColor,
  bool barrierDismissible = false,
  String? successMessage,
  String Function(Object error)? errorMessageBuilder,
}) async {
  if (onDelete == null) return;

  final resolvedRowId = rowId?.toString().trim();
  if (resolvedRowId == null || resolvedRowId.isEmpty) return;

  final shouldDelete = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmButtonColor ?? Colors.red.shade600,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (!context.mounted) return;
  if (shouldDelete != true) return;

  final messenger = ScaffoldMessenger.of(context);

  try {
    final result = await onDelete(id: resolvedRowId);
    if (!context.mounted) return;

    final message = (result != null && result.isNotEmpty)
        ? result
        : (successMessage ?? 'Item deleted.');
    messenger.showSnackBar(SnackBar(content: Text(message)));
  } catch (error) {
    if (!context.mounted) return;

    final message =
        errorMessageBuilder?.call(error) ??
        'Could not complete the operation: $error';
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
