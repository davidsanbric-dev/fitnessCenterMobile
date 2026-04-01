import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';

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
    final items = <PopupMenuEntry<String>>[];

    if (onViewFile != null) {
      items.add(
        const PopupMenuItem(
          value: 'viewFile',
          child: Row(
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                color: AppTheme.brandBlue,
                size: 18,
              ),
              SizedBox(width: 8),
              Text('View file'),
            ],
          ),
        ),
      );
    }

    if (onViewDerivation != null) {
      items.add(
        const PopupMenuItem(
          value: 'viewDerivation',
          child: Row(
            children: [
              Icon(
                Icons.account_tree_outlined,
                color: AppTheme.brandBlue,
                size: 18,
              ),
              SizedBox(width: 8),
              Text('View referral'),
            ],
          ),
        ),
      );
    }

    if (onView != null) {
      items.add(
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                color: AppTheme.brandBlue,
                size: 18,
              ),
              SizedBox(width: 8),
              Text('View details'),
            ],
          ),
        ),
      );
    }

    if (onConfirmReservation != null) {
      items.add(
        const PopupMenuItem(
          value: 'confirmReservation',
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppTheme.brandBlue,
                size: 18,
              ),
              SizedBox(width: 8),
              Text('CONFIRM BOOKING'),
            ],
          ),
        ),
      );
    }

    if (onCancelReservation != null) {
      items.add(
        const PopupMenuItem(
          value: 'cancelReservation',
          child: Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppTheme.brandBlue, size: 18),
              SizedBox(width: 8),
              Text('CANCEL BOOKING'),
            ],
          ),
        ),
      );
    }

    if (onUpdateBookingStatus != null) {
      items.add(
        const PopupMenuItem(
          value: 'updateBookingStatus',
          child: Row(
            children: [
              Icon(Icons.sync_alt, color: AppTheme.brandBlue, size: 18),
              SizedBox(width: 8),
              Text('Actualizar Estado'),
            ],
          ),
        ),
      );
    }

    if (onEdit != null) {
      items.add(
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: AppTheme.brandBlue, size: 18),
              SizedBox(width: 8),
              Text('Editar'),
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
              Icon(Icons.delete_outline, color: Colors.red[400], size: 18),
              const SizedBox(width: 8),
              const Text('Eliminar'),
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
    //           Icon(Icons.assignment_ind, color: Colors.blueGrey, size: 18),
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
              Icon(Icons.vpn_key, color: Colors.blueAccent, size: 18),
              SizedBox(width: 8),
              Text('Asignar permiso'),
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
              Icon(
                Icons.remove_circle_outline,
                color: Colors.redAccent,
                size: 18,
              ),
              SizedBox(width: 8),
              Text('Remover permiso'),
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
          icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black87),
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
