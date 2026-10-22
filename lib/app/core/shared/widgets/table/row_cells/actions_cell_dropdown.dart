import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// 🧩 Actions dropdown (context menu)
class ActionsDropdown extends StatelessWidget {
  final VoidCallback? onViewFile;
  final VoidCallback? onViewDerivation;
  final VoidCallback? onView;
  final VoidCallback? onConfirmReservation;
  final VoidCallback? onCancelReservation;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAssignRole;
  final VoidCallback? onAssignPermission;
  final VoidCallback? onRemovePermission;
  final VoidCallback? onUpdateBookingStatus;

  const ActionsDropdown({
    this.onViewFile,
    this.onViewDerivation,
    this.onView,
    this.onConfirmReservation,
    this.onCancelReservation,
    this.onEdit,
    this.onDelete,
    this.onAssignRole,
    this.onAssignPermission,
    this.onRemovePermission,
    this.onUpdateBookingStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <PopupMenuEntry<String>>[];
    final brand = AppTheme.brandAccentColor(context);

    if (onViewFile != null) {
      items.add(
        PopupMenuItem(
          value: 'viewFile',
          child: Row(
            children: [
              Icon(LucideIcons.fileText, color: brand, size: 18),
              const SizedBox(width: 8),
              const Text('View file'),
            ],
          ),
        ),
      );
    }

    if (onViewDerivation != null) {
      items.add(
        PopupMenuItem(
          value: 'viewDerivation',
          child: Row(
            children: [
              Icon(LucideIcons.gitBranch, color: brand, size: 18),
              const SizedBox(width: 8),
              const Text('View referral'),
            ],
          ),
        ),
      );
    }

    if (onView != null) {
      items.add(
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(LucideIcons.eye, color: brand, size: 18),
              const SizedBox(width: 8),
              Text(l10n.bookingsViewDetails),
            ],
          ),
        ),
      );
    }

    if (onConfirmReservation != null) {
      items.add(
        PopupMenuItem(
          value: 'confirmReservation',
          child: Row(
            children: [
              Icon(LucideIcons.checkCircle, color: brand, size: 18),
              const SizedBox(width: 8),
              Text(l10n.bookingsConfirmBooking),
            ],
          ),
        ),
      );
    }

    if (onCancelReservation != null) {
      items.add(
        PopupMenuItem(
          value: 'cancelReservation',
          child: Row(
            children: [
              Icon(LucideIcons.xCircle, color: brand, size: 18),
              const SizedBox(width: 8),
              Text(l10n.bookingsCancelBooking),
            ],
          ),
        ),
      );
    }

    if (onUpdateBookingStatus != null) {
      items.add(
        PopupMenuItem(
          value: 'updateBookingStatus',
          child: Row(
            children: [
              Icon(LucideIcons.refreshCw, color: brand, size: 18),
              const SizedBox(width: 8),
              Text(l10n.bookingsUpdateStatus),
            ],
          ),
        ),
      );
    }

    if (onEdit != null) {
      items.add(
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(LucideIcons.edit, color: brand, size: 18),
              const SizedBox(width: 8),
              const Text('Edit'),
            ],
          ),
        ),
      );
    }

    if (onDelete != null) {
      items.add(
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(LucideIcons.trash2, color: Colors.red[400], size: 18),
              const SizedBox(width: 8),
              const Text('Delete'),
            ],
          ),
        ),
      );
    }

    // if (onAssignRole != null) {
    //   items.add(
    //     const PopupMenuItem(
    //       value: 'assignRole',
    //       child: Row(
    //         children: const [
    //           Icon(LucideIcons.user, color: Colors.blueGrey, size: 18),
    //           SizedBox(width: 8),
    //           Text('Asignar rol'),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    if (onAssignPermission != null) {
      items.add(
        const PopupMenuItem(
          value: 'assignPermission',
          child: Row(
            children: [
              Icon(LucideIcons.key, color: Colors.blueAccent, size: 18),
              SizedBox(width: 8),
              Text('Assign permission'),
            ],
          ),
        ),
      );
    }

    if (onRemovePermission != null) {
      items.add(
        const PopupMenuItem(
          value: 'removePermission',
          child: Row(
            children: [
              Icon(LucideIcons.minusCircle, color: Colors.redAccent, size: 18),
              SizedBox(width: 8),
              Text('Remove permission'),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 48,
      child: Align(
        child: PopupMenuButton<String>(
          tooltip: 'Row actions',
          icon: Icon(
            LucideIcons.moreHorizontal,
            size: 20,
            color: AppTheme.mutedTextColor(context),
          ),
          onSelected: (value) {
            switch (value) {
              case 'viewFile':
                onViewFile?.call();
                break;
              case 'viewDerivation':
                onViewDerivation?.call();
                break;
              case 'view':
                onView?.call();
                break;
              case 'confirmReservation':
                onConfirmReservation?.call();
                break;
              case 'cancelReservation':
                onCancelReservation?.call();
                break;
              case 'updateBookingStatus':
                onUpdateBookingStatus?.call();
                break;
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
              case 'assignRole':
                onAssignRole?.call();
                break;
              case 'assignPermission':
                onAssignPermission?.call();
                break;
              case 'removePermission':
                onRemovePermission?.call();
                break;
            }
          },
          itemBuilder: (context) => items,
        ),
      ),
    );
  }
}
