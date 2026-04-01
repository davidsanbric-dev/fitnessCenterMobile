import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/filter_boxes/triple_option_filter_box.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:flutter/material.dart';

class SchedulingModeFilterBox extends StatelessWidget {
  const SchedulingModeFilterBox({
    super.key,
    this.title = 'Booking Options',
    this.accentColor = AppTheme.brandBlue,
    required this.selectedMode,
    this.onChanged,
  });

  final String title;
  final Color accentColor;
  final SchedulingMode? selectedMode;
  final ValueChanged<SchedulingMode>? onChanged;

  static const double _optionHeight = 160;
  static const double _thirdOptionHeight = 120;

  static const List<FilterOption<SchedulingMode>> _options = [
    FilterOption<SchedulingMode>(
      value: SchedulingMode.byDisciplineTrainer,
      label: 'By Discipline/Trainer',
      iconPath: 'assets/icons/discipline_icon.png',
    ),
    FilterOption<SchedulingMode>(
      value: SchedulingMode.byService,
      label: 'By Class Type',
      iconData: Icons.category_outlined,
    ),
    FilterOption<SchedulingMode>(
      value: SchedulingMode.online,
      label: 'Online Sessions',
      iconData: Icons.videocam_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TripleOptionFilterBox<SchedulingMode>(
      title: title,
      accentColor: accentColor,
      options: _options,
      selectedValue: selectedMode,
      onChanged: onChanged,
      optionBuilder:
          (
            context,
            option, {
            required isSelected,
            required accentColor,
            required onPressed,
          }) {
            final buttonHeight = option.value == SchedulingMode.online
                ? _thirdOptionHeight
                : _optionHeight;

            return SizedBox(
              height: buttonHeight,
              child: _FixedHeightOptionButton<SchedulingMode>(
                option: option,
                isSelected: isSelected,
                accentColor: accentColor,
                onPressed: onPressed,
              ),
            );
          },
    );
  }
}

class _FixedHeightOptionButton<T> extends StatelessWidget {
  const _FixedHeightOptionButton({
    required this.option,
    required this.isSelected,
    required this.accentColor,
    required this.onPressed,
  });

  final FilterOption<T> option;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? accentColor : Colors.white;
    final borderColor = isSelected
        ? accentColor
        : accentColor.withValues(alpha: 0.6);
    final foregroundColor = isSelected ? Colors.white : Colors.grey.shade700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.4),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 24, 10, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: option.iconData != null
                      ? Icon(option.iconData, size: 28, color: foregroundColor)
                      : Image.asset(
                          option.iconPath!,
                          height: 28,
                          width: 28,
                          errorBuilder: (context, _, __) {
                            return Icon(
                              Icons.fitness_center,
                              color: foregroundColor,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
