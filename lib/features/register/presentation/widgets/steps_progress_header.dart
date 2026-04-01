import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';

class StepsProgressHeader extends StatelessWidget {
  const StepsProgressHeader({super.key, this.currentStep = 1});

  final int currentStep;

  static const List<_StepData> _steps = [
    _StepData('Step 1', 'Your details'),
    _StepData('Step 2', 'Digital signature'),
    _StepData('Step 3', 'Verification'),
    _StepData('Step 4', 'Create password'),
  ];

  @override
  Widget build(BuildContext context) {
    final int clampedStep = currentStep.clamp(1, _steps.length);
    const Color activeColor = AppTheme.brandBlue;
    final Color inactiveColor = Colors.grey.shade400;
    final Color textInactive = Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(_steps.length * 2 - 1, (index) {
            if (index.isEven) {
              final stepIndex = index ~/ 2;
              final isActive = stepIndex + 1 == clampedStep;
              final isCompleted = stepIndex + 1 < clampedStep;

              return _StepIndicator(
                isActive: isActive,
                isCompleted: isCompleted,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              );
            }

            final segmentIndex = index ~/ 2;
            final segmentActive = segmentIndex + 1 < clampedStep;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: segmentActive
                      ? activeColor.withValues(alpha: 0.6)
                      : inactiveColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = index + 1 == clampedStep;

            return Expanded(
              child: Column(
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive ? activeColor : textInactive,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textInactive,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.isActive,
    required this.isCompleted,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool isActive;
  final bool isCompleted;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = (isActive || isCompleted)
        ? activeColor
        : inactiveColor;
    final Color fillColor = isActive
        ? activeColor
        : (isCompleted
              ? activeColor.withValues(alpha: 0.35)
              : inactiveColor.withValues(alpha: 0.35));

    return SizedBox(
      width: 24,
      height: 24,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fillColor),
          ),
        ),
      ),
    );
  }
}

class _StepData {
  const _StepData(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
