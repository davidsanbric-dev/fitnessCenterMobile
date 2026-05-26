import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class InlineOptionsDropdownTwoStage {
  const InlineOptionsDropdownTwoStage({
    required this.primaryTitle,
    required this.primaryOptions,
    required this.onPrimarySelected,
    required this.secondaryTitle,
    required this.secondaryOptions,
    this.emptyPrimaryLabel,
    this.emptySecondaryLabel,
  });

  final String primaryTitle;
  final List<String> primaryOptions;
  final Future<void> Function(String value) onPrimarySelected;
  final String secondaryTitle;
  final List<String> secondaryOptions;
  final String? emptyPrimaryLabel;
  final String? emptySecondaryLabel;
}

class InlineOptionsDropdown extends StatefulWidget {
  const InlineOptionsDropdown({
    super.key,
    required this.title,
    required this.options,
    required this.onOptionSelected,
    required this.filterText,
    required this.maxHeight,
    this.color = AppTheme.brandBlue,
    this.twoStage,
    this.stageResetKey,
  });

  final String title;
  final List<String> options;
  final ValueChanged<String> onOptionSelected;
  final String filterText;
  final double maxHeight;
  final Color color;
  final InlineOptionsDropdownTwoStage? twoStage;
  final Object? stageResetKey;

  @override
  State<InlineOptionsDropdown> createState() => _InlineOptionsDropdownState();
}

class _InlineOptionsDropdownState extends State<InlineOptionsDropdown> {
  _InlineOptionsStage _stage = _InlineOptionsStage.single;
  bool _isLoadingSecondary = false;
  String? _selectedPrimaryLabel;

  @override
  void initState() {
    super.initState();
    _resetStage();
  }

  @override
  void didUpdateWidget(covariant InlineOptionsDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resetKeyChanged = widget.stageResetKey != oldWidget.stageResetKey;
    final stageModeChanged =
        (oldWidget.twoStage == null) != (widget.twoStage == null);
    if (resetKeyChanged || stageModeChanged) {
      setState(_resetStage);
    }
  }

  void _resetStage() {
    _stage = widget.twoStage == null
        ? _InlineOptionsStage.single
        : _InlineOptionsStage.primary;
    _isLoadingSecondary = false;
    _selectedPrimaryLabel = null;
  }

  Future<void> _handlePrimarySelected(String value) async {
    final flow = widget.twoStage;
    if (flow == null) return;
    setState(() {
      _selectedPrimaryLabel = value;
      _stage = _InlineOptionsStage.secondary;
      _isLoadingSecondary = true;
    });

    try {
      await flow.onPrimarySelected(value);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSecondary = false;
        });
      }
    }
  }

  void _handleBack() {
    setState(() {
      _stage = _InlineOptionsStage.primary;
      _isLoadingSecondary = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final flow = widget.twoStage;
    final showSecondary =
        flow != null && _stage == _InlineOptionsStage.secondary;

    final String title;
    final List<String> options;
    final String? emptyLabel;
    final void Function(String) onOptionTap;

    if (flow == null) {
      title = widget.title;
      options = widget.options;
      emptyLabel = null;
      onOptionTap = widget.onOptionSelected;
    } else {
      title = showSecondary ? flow.secondaryTitle : flow.primaryTitle;
      options = showSecondary ? flow.secondaryOptions : flow.primaryOptions;
      emptyLabel = showSecondary
          ? flow.emptySecondaryLabel
          : flow.emptyPrimaryLabel;
      onOptionTap = showSecondary
          ? widget.onOptionSelected
          : _handlePrimarySelected;
    }

    final trimmedFilter = widget.filterText.trim();
    final hasFilter = trimmedFilter.isNotEmpty;
    final normalizedFilter = trimmedFilter.toLowerCase();
    final baseOptions = hasFilter
        ? options
              .where(
                (option) => option.toLowerCase().contains(normalizedFilter),
              )
              .toList(growable: false)
        : options;
    final filteredOptions = baseOptions;
    final shouldShowNoMatches =
        hasFilter && options.isNotEmpty && baseOptions.isEmpty;

    return Material(
      elevation: 12,
      color: widget.color,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: widget.maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InlineDropdownHeader(
              title: title,
              onBack: showSecondary ? _handleBack : null,
              subtitle: showSecondary ? _selectedPrimaryLabel : null,
            ),
            const Divider(height: 1, color: Colors.white24),
            Expanded(
              child: Stack(
                children: [
                  if (_isLoadingSecondary)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else if (filteredOptions.isEmpty)
                    Center(
                      child: Text(
                        shouldShowNoMatches
                            ? 'No hay coincidencias.'
                            : (emptyLabel ?? 'No hay opciones disponibles.'),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    )
                  else
                    ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: filteredOptions.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      itemBuilder: (context, index) {
                        final option = filteredOptions[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            option,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          onTap: () => onOptionTap(option),
                        );
                      },
                    ),
                  _InlineBottomFadeOverlay(color: widget.color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineDropdownHeader extends StatelessWidget {
  const _InlineDropdownHeader({
    required this.title,
    this.subtitle,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final showBack = onBack != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBack)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(LucideIcons.chevronLeft),
                  color: Colors.white,
                  iconSize: 18,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              if (showBack) const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineBottomFadeOverlay extends StatelessWidget {
  const _InlineBottomFadeOverlay({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _InlineOptionsStage { single, primary, secondary }
