import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/filter_boxes/filter_box_option_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CapabilitiesSubgroupFilterBox extends StatelessWidget {
  const CapabilitiesSubgroupFilterBox({
    super.key,
    this.accentColor,
    required this.subgroup,
    required this.onCapabilitySelected,
    this.groupLabel,
    this.emptyStateMessage,
    this.isLoading = false,
  });

  final Color? accentColor;
  final List<CapabilityDto> subgroup;
  final ValueChanged<CapabilityDto> onCapabilitySelected;
  final String? groupLabel;
  final String? emptyStateMessage;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? AppTheme.brandAccentColor(context);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (subgroup.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          emptyStateMessage ??
              'No subcategories available for the selected group.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCardColor(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppTheme.surfaceCardBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a subcategory',
                  style: AppTheme.titleMediumEmphasis(context),
                ),
                if (groupLabel != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8, top: 2),
                        child: Icon(LucideIcons.tags, size: 16, color: accent),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Group: ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(text: groupLabel),
                            ],
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: accent.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subgroup.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.75,
              ),
              itemBuilder: (context, index) {
                final item = subgroup[index];

                return FilterBoxOptionButton(
                  label: item.description,
                  iconData: LucideIcons.tags,
                  iconContainerSize: 34,
                  iconAlignment: Alignment.bottomRight,
                  iconOffset: const Offset(2, 2),
                  labelStyle: const TextStyle(fontSize: 15, height: 1.2),
                  labelPadding: const EdgeInsets.only(right: 4, bottom: 36),
                  onTap: () => onCapabilitySelected(item),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
