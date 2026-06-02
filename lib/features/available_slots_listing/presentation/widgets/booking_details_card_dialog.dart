import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/info_card.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/dialogs/row_details_card_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

mixin BookingDetailsCardDialog {
  static Future<void> show(
    BuildContext context, {
    required BookingDto booking,
  }) {
    final sections = _buildSections(context, booking);
    return RowDetailsCardDialog.show(
      context,
      title: 'Booking Details',
      sections: sections,
    );
  }

  static List<RowDetailsSection> _buildSections(
    BuildContext context,
    BookingDto detail,
  ) {
    final generalItems = _buildGeneralItems(detail);
    final memberItems = _buildMemberItems(detail);
    final trainerItems = _buildTrainerItems(detail);
    final serviceItems = _buildServiceItems(context, detail);
    return [
      RowDetailsSection(title: 'General Information', items: generalItems),
      RowDetailsSection(title: 'Member', items: memberItems),
      if (trainerItems.isNotEmpty)
        RowDetailsSection(title: 'Trainer', items: trainerItems),
      if (serviceItems.isNotEmpty)
        RowDetailsSection(title: 'Class', items: serviceItems),
    ];
  }

  static List<RowDetailsItem> _buildGeneralItems(BookingDto detail) {
    final locationParts = <String>[];
    if (detail.locationName.isNotEmpty) {
      locationParts.add(detail.locationName);
    }

    return [
      RowDetailsItem(
        label: 'Status',
        value: detail.state.isEmpty ? 'No status' : detail.state,
        icon: LucideIcons.flag,
      ),
      RowDetailsItem(
        label: 'Created At',
        value: formatDateTimeLabel(detail.creationDate),
        icon: LucideIcons.clock,
      ),
      RowDetailsItem(
        label: 'Scheduled At',
        value: formatDateTimeLabel(detail.schedulingDate),
        icon: LucideIcons.calendarCheck,
      ),
      RowDetailsItem(
        label: 'Duration',
        value: detail.duration > 0 ? '${detail.duration} min' : 'Not defined',
        icon: LucideIcons.timer,
      ),
      RowDetailsItem(
        label: 'Club',
        value: locationParts.isEmpty
            ? 'Not available'
            : locationParts.join(' · '),
        icon: LucideIcons.building2,
      ),
    ];
  }

  static List<RowDetailsItem> _buildMemberItems(BookingDto detail) => [
    RowDetailsItem(
      label: 'Name',
      value: detail.memberName.isEmpty ? 'No name' : detail.memberName,
      icon: LucideIcons.user,
    ),
    RowDetailsItem(
      label: 'RUT',
      value: detail.memberRut.isEmpty ? 'Not available' : detail.memberRut,
      icon: LucideIcons.idCard,
    ),
    RowDetailsItem(
      label: 'Phone',
      value: detail.memberPhone.isEmpty ? 'Not available' : detail.memberPhone,
      icon: LucideIcons.phone,
    ),
  ];

  static List<RowDetailsItem> _buildTrainerItems(BookingDto detail) {
    final items = <RowDetailsItem>[];

    if ((detail.trainerName ?? '').isNotEmpty) {
      items.add(
        RowDetailsItem(
          label: 'Trainer',
          value: detail.trainerName!,
          icon: LucideIcons.dumbbell,
        ),
      );
    }

    if ((detail.disciplineName ?? '').isNotEmpty) {
      items.add(
        RowDetailsItem(
          label: 'Discipline',
          value: detail.disciplineName!,
          icon: LucideIcons.star,
        ),
      );
    }

    return items;
  }

  static List<RowDetailsItem> _buildServiceItems(
    BuildContext context,
    BookingDto detail,
  ) {
    final items = <RowDetailsItem>[];

    if (detail.serviceName != null && detail.serviceName!.isNotEmpty) {
      items.add(
        RowDetailsItem(
          label: 'Class',
          value: detail.serviceName!,
          icon: LucideIcons.dumbbell,
        ),
      );
    }

    final preparation = detail.preparation?.trim() ?? '';
    if (preparation.isNotEmpty) {
      items.add(
        RowDetailsItem(
          label: 'Preparation',
          value: 'View Preparation',
          icon: LucideIcons.fileText,
          onTap: () => _showPreparationDialog(context, preparation),
        ),
      );
    }

    if (items.isEmpty) {
      return const [];
    }

    return items;
  }

  static Future<void> _showPreparationDialog(
    BuildContext context,
    String preparationHtml,
  ) {
    final preparationText = formatHTMLContent(preparationHtml);
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          'Preparation',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
          child: SingleChildScrollView(
            child: SelectableText(
              preparationText.isEmpty
                  ? 'No preparation instructions available.'
                  : preparationText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.brandBlue),
            ),
          ),
        ],
      ),
    );
  }

}
