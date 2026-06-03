import 'dart:math' as math;

import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header_scope.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_card_height_scope.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/book_session_flow.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Opens the full "Book a Session" flow ([BookSessionFlow]) inside a centered
/// dialog sized to comfortably hold every stage — from the scheduling-mode
/// selection through the field filters to the available-slots table.
///
/// The dialog is given a forced bounded size: the by-discipline/trainer branch
/// relies on `StackFit.expand` (needs bounded height), and the same height is
/// fed to [TableCardHeightScope] so the inner tables size themselves relative
/// to the dialog instead of the full screen.
Future<void> showBookSessionDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final media = MediaQuery.of(dialogContext).size;
      final dialogHeight = media.height * 0.88;
      final dialogWidth = math.min(560.0, media.width - 32);

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: TableCardHeightScope(
            availableHeight: dialogHeight,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: PageHeaderScope(
                    showLogout: false,
                    child: BookSessionFlow(scrollBottomPadding: 24),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
