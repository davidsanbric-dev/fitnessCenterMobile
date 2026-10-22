import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class MenuTriggerButton extends StatelessWidget {
  const MenuTriggerButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(LucideIcons.menu),
        tooltip: 'Menu',
        color: Colors.grey.shade800,
        onPressed: onPressed,
      ),
    );
  }
}
