import 'package:flutter/material.dart';

class AssignRowValueOption {
  const AssignRowValueOption({required this.id, required this.label});

  final String id;
  final String label;
}

List<AssignRowValueOption> buildOptions<T>({
  required Iterable<T> source,
  required String? Function(T item) idSelector,
  String? Function(T item)? labelSelector,
  String Function(String value)? normalizeId,
  bool unique = true,
}) {
  final options = <AssignRowValueOption>[];
  final seen = <String>{};
  final normalize = normalizeId ?? (value) => value;

  for (final item in source) {
    final rawId = idSelector(item);
    if (rawId == null) continue;
    final id = rawId.trim();
    if (id.isEmpty) continue;

    if (unique) {
      final normalized = normalize(id);
      if (normalized.isEmpty || !seen.add(normalized)) {
        continue;
      }
    }

    final rawLabel = labelSelector?.call(item)?.trim();
    final label = rawLabel != null && rawLabel.isNotEmpty ? rawLabel : id;
    options.add(AssignRowValueOption(id: id, label: label));
  }

  return options;
}

typedef AssignRowValueSubmit = Future<String?> Function(String value);
typedef AssignRowValueErrorBuilder = String Function(Object error);

Future<String?> showAssignRowValueDialog({
  required BuildContext context,
  required String title,
  required String fieldLabel,
  required String emptySelectionMessage,
  required List<AssignRowValueOption> options,
  required AssignRowValueSubmit onSubmit,
  String? initialValue,
  String confirmLabel = 'Assign',
  String cancelLabel = 'Cancel',
  bool barrierDismissible = false,
  AssignRowValueErrorBuilder? errorMessageBuilder,
}) async {
  if (options.isEmpty) return null;

  final formKey = GlobalKey<FormState>();
  var selectedValue = initialValue;
  if (selectedValue == null ||
      selectedValue.trim().isEmpty ||
      !options.any((option) => option.id == selectedValue)) {
    selectedValue = options.first.id;
  }

  String? submitError;
  var isSubmitting = false;

  return showDialog<String?>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedValue,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: fieldLabel),
                  items: options
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option.id,
                          child: Text(
                            option.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return emptySelectionMessage;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedValue = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (submitError != null)
                  Text(submitError!, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: isSubmitting
                ? null
                : () {
                    Navigator.of(dialogContext).pop();
                  },
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () async {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }

                    setState(() {
                      submitError = null;
                      isSubmitting = true;
                    });

                    final navigator = Navigator.of(dialogContext);
                    try {
                      final result = await onSubmit(selectedValue!);
                      if (!dialogContext.mounted) return;

                      if (result == null) {
                        navigator.pop(selectedValue);
                      } else {
                        setState(() {
                          submitError = result;
                          isSubmitting = false;
                        });
                      }
                    } catch (error) {
                      if (!dialogContext.mounted) return;

                      setState(() {
                        submitError =
                            errorMessageBuilder?.call(error) ??
                            error.toString();
                        isSubmitting = false;
                      });
                    }
                  },
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(confirmLabel),
          ),
        ],
      ),
    ),
  );
}
