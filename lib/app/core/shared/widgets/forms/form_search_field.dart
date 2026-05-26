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
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final double? fontSize;
  final bool showUnderline;

  void _moveCursorToEnd() {
    final text = controller.text;
    controller.selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  Widget build(BuildContext context) {
    final underlineBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: showUnderline ? Colors.grey.shade400 : Colors.transparent,
      ),
    );
    final focusedUnderlineBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: showUnderline ? AppTheme.brandBlue : Colors.transparent,
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
        suffixIcon: const Icon(LucideIcons.search, color: AppTheme.brandBlue),
        enabledBorder: underlineBorder,
        focusedBorder: focusedUnderlineBorder,
      ),
    );
  }
}
