import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class InputOptionsDropupTwoStage {
  const InputOptionsDropupTwoStage({
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

class InputOptionsDropupSheet extends StatefulWidget {
  const InputOptionsDropupSheet({
    super.key,
    required this.title,
    required this.options,
    required this.onOptionSelected,
    this.color = AppTheme.brandBlue,
    this.heightFraction = 0.55,
    this.twoStage,
    this.stageResetKey,
    this.filterText = '',
  });

  final String title;
  final List<String> options;
  final ValueChanged<String> onOptionSelected;
  final Color color;
  final double heightFraction;
  final InputOptionsDropupTwoStage? twoStage;
  final Object? stageResetKey;
  final String filterText;

  @override
  State<InputOptionsDropupSheet> createState() =>
      _InputOptionsDropupSheetState();
}

class _InputOptionsDropupSheetState extends State<InputOptionsDropupSheet> {
  _InputOptionsStage _stage = _InputOptionsStage.single;
  bool _isLoadingSecondary = false;
  String? _selectedPrimaryLabel;

  @override
  void initState() {
    super.initState();
    _resetStage();
  }

  @override
  void didUpdateWidget(InputOptionsDropupSheet oldWidget) {
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
        ? _InputOptionsStage.single
        : _InputOptionsStage.primary;
    _isLoadingSecondary = false;
    _selectedPrimaryLabel = null;
  }

  Future<void> _handlePrimarySelected(String value) async {
    final flow = widget.twoStage;
    if (flow == null) return;
    setState(() {
      _selectedPrimaryLabel = value;
      _stage = _InputOptionsStage.secondary;
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
      _stage = _InputOptionsStage.primary;
      _isLoadingSecondary = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight =
        MediaQuery.of(context).size.height * widget.heightFraction;
    final flow = widget.twoStage;
    final showSecondary =
        flow != null && _stage == _InputOptionsStage.secondary;

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
    final filteredOptions = hasFilter
        ? options
              .where(
                (option) => option.toLowerCase().contains(normalizedFilter),
              )
              .toList(growable: false)
        : options;
    final shouldShowNoMatches =
        hasFilter && options.isNotEmpty && filteredOptions.isEmpty;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: sheetHeight,
        child: Material(
          color: widget.color,
          elevation: 12,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          borderRadius: _sheetRadius,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                title: title,
                onBack: showSecondary ? _handleBack : null,
                subtitle: showSecondary ? _selectedPrimaryLabel : null,
              ),
              const Divider(color: Colors.white24, height: 1),
              Expanded(
                child: Stack(
                  children: [
                    if (_isLoadingSecondary)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    else if (filteredOptions.isEmpty)
                      Center(
                        child: Text(
                          shouldShowNoMatches
                              ? 'No hay coincidencias.'
                              : (emptyLabel ?? 'No hay opciones disponibles.'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      )
                    else
                      ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filteredOptions.length,
                        separatorBuilder: (_, __) => Divider(
                          color: Colors.white.withValues(alpha: 0.35),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final option = filteredOptions[index];
                          return ListTile(
                            title: Text(
                              option,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            onTap: () => onOptionTap(option),
                          );
                        },
                      ),
                    const _BottomFadeOverlay(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.subtitle, this.onBack});

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final showBack = onBack != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 24, 12),
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
              if (showBack) const SizedBox(width: 8),
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
            const SizedBox(height: 4),
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

class _BottomFadeOverlay extends StatelessWidget {
  const _BottomFadeOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.brandBlue.withValues(alpha: 0.1),
                AppTheme.brandBlue.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _sheetRadius = BorderRadius.only(
  topLeft: Radius.circular(36),
  topRight: Radius.circular(36),
);

enum _InputOptionsStage { single, primary, secondary }
