import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/filter_boxes/filter_box_option_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CapabilitiesGroupFilterBox extends StatelessWidget {
  const CapabilitiesGroupFilterBox({
    super.key,
    this.accentColor,
    required this.groups,
    required this.onGroupSelected,
    this.emptyStateMessage,
    this.isLoading = false,
  });

  final Color? accentColor;
  final List<CapabilityDto> groups;
  final ValueChanged<CapabilityDto> onGroupSelected;
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

    if (groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          emptyStateMessage ??
              'No class category groups are available right now.',
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
            child: Text(
              'What type of class are you looking for?',
              style: AppTheme.titleMediumEmphasis(context),
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
              itemCount: groups.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.75,
              ),
              itemBuilder: (context, index) {
                final group = groups[index];

                return FilterBoxOptionButton(
                  label: group.description,
                  iconData: LucideIcons.tags,
                  iconContainerSize: 34,
                  iconAlignment: Alignment.bottomRight,
                  iconOffset: const Offset(2, 2),
                  labelStyle: const TextStyle(fontSize: 15, height: 1.2),
                  labelPadding: const EdgeInsets.only(right: 4, bottom: 36),
                  onTap: () => onGroupSelected(group),
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
