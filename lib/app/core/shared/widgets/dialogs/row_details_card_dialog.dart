import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';

class RowDetailsCardDialog extends StatelessWidget {
  const RowDetailsCardDialog({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<RowDetailsSection> sections;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<RowDetailsSection> sections,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => RowDetailsCardDialog(title: title, sections: sections),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: sections
                .map((section) => _SectionView(section: section))
                .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(color: AppTheme.brandAccentColor(context)),
          ),
        ),
      ],
    );
  }
}

class RowDetailsSection {
  const RowDetailsSection({required this.title, required this.items});

  final String title;
  final List<RowDetailsItem> items;
}

class RowDetailsItem {
  const RowDetailsItem({
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section});

  final RowDetailsSection section;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...section.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8, top: 2),
                      child: Icon(
                        item.icon,
                        size: 16,
                        color: AppTheme.brandAccentColor(context),
                      ),
                    ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.label,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: item.onTap != null
                                  ? TextButton(
                                      onPressed: item.onTap,
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppTheme.brandAccentColor(context),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      child: Text(
                                        item.value.isEmpty ? 'Ver' : item.value,
                                        textAlign: TextAlign.right,
                                      ),
                                    )
                                  : Text(
                                      item.value.isEmpty ? '—' : item.value,
                                      textAlign: TextAlign.right,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
