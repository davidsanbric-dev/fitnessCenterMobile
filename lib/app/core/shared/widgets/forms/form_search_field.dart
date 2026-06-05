import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.readOnly = false,
    this.onTap,
    this.fontSize,
    this.showUnderline = true,
    this.showClearButton = false,
    this.onCleared,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final double? fontSize;
  final bool showUnderline;

  /// When true, a clear (x) button is shown at the end of the field (before the
  /// search icon) whenever the field holds text. Tapping it empties the field.
  final bool showClearButton;

  /// Called after the field is cleared via the clear (x) button.
  final VoidCallback? onCleared;

  void _moveCursorToEnd() {
    final text = controller.text;
    controller.selection = TextSelection.collapsed(offset: text.length);
  }

  void _handleClear() {
    controller.clear();
    onCleared?.call();
  }

  Widget _buildSuffixIcon(Color brand) {
    final searchIcon = Icon(LucideIcons.search, color: brand);
    if (!showClearButton) {
      return searchIcon;
    }
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final clearButton = value.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
                color: Colors.grey.shade600,
                tooltip: 'Clear',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _handleClear,
              );
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            clearButton,
            if (value.text.isNotEmpty) const SizedBox(width: 6),
            child!,
          ],
        );
      },
      child: searchIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final underlineBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: showUnderline ? Colors.grey.shade400 : Colors.transparent,
      ),
    );
    final brand = AppTheme.brandAccentColor(context);
    final focusedUnderlineBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: showUnderline ? brand : Colors.transparent,
        width: showUnderline ? 1.5 : 0,
      ),
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      showCursor: !readOnly,
      enableInteractiveSelection: !readOnly,
      onTap: () {
        if (!readOnly) {
          _moveCursorToEnd();
        }
        onTap?.call();
      },
      style: fontSize != null ? TextStyle(fontSize: fontSize) : null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: fontSize != null ? TextStyle(fontSize: fontSize) : null,
        contentPadding: const EdgeInsets.only(bottom: 8),
        suffixIcon: _buildSuffixIcon(brand),
        enabledBorder: underlineBorder,
        focusedBorder: focusedUnderlineBorder,
      ),
    );
  }
}
