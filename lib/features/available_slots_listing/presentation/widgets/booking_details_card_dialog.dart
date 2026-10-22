import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/app/core/utils/format/date_time.dart';
import 'package:fitnesscenter_mobile/app/core/utils/format/info_card.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/dialogs/row_details_card_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

mixin BookingDetailsCardDialog {
  static Future<void> show(
    BuildContext context, {
    required BookingDto booking,
  }) {
    final sections = _buildSections(context, booking);
    return RowDetailsCardDialog.show(
      context,
      title: AppLocalizations.of(context).bookingDetailsTitle,
      sections: sections,
    );
  }

  static List<RowDetailsSection> _buildSections(
    BuildContext context,
    BookingDto detail,
  ) {
    final generalItems = _buildGeneralItems(context, detail);
    final memberItems = _buildMemberItems(context, detail);
    final trainerItems = _buildTrainerItems(context, detail);
    final serviceItems = _buildServiceItems(context, detail);
    final feedbackItems = _buildFeedbackItems(context, detail);
    return [
      RowDetailsSection(
        title: AppLocalizations.of(context).commonGeneralInfo,
        items: generalItems,
      ),
      RowDetailsSection(
        title: AppLocalizations.of(context).commonMember,
        items: memberItems,
      ),
      if (trainerItems.isNotEmpty)
        RowDetailsSection(
          title: AppLocalizations.of(context).commonTrainer,
          items: trainerItems,
        ),
      if (serviceItems.isNotEmpty)
        RowDetailsSection(
          title: AppLocalizations.of(context).commonClass,
          items: serviceItems,
        ),
      if (feedbackItems.isNotEmpty)
        RowDetailsSection(
          title: AppLocalizations.of(context).commonSessionFeedback,
          items: feedbackItems,
        ),
    ];
  }

  static List<RowDetailsItem> _buildFeedbackItems(
    BuildContext context,
    BookingDto detail,
  ) {
    final notes = detail.notes?.trim() ?? '';
    if (notes.isEmpty) {
      return const [];
    }
    return [
      RowDetailsItem(
        label: AppLocalizations.of(context).commonTrainerNotes,
        value: notes,
        icon: LucideIcons.messageSquare,
      ),
    ];
  }

  static List<RowDetailsItem> _buildGeneralItems(
    BuildContext context,
    BookingDto detail,
  ) {
    return [
      RowDetailsItem(
        label: AppLocalizations.of(context).commonStatus,
        value: detail.state.isEmpty
            ? AppLocalizations.of(context).commonNoStatus
            : detail.state,
        icon: LucideIcons.flag,
      ),
      RowDetailsItem(
        label: AppLocalizations.of(context).commonCreatedAt,
        value: formatDateTimeLabel(detail.creationDate),
        icon: LucideIcons.clock,
      ),
      RowDetailsItem(
        label: AppLocalizations.of(context).commonScheduledAt,
        value: formatDateTimeLabel(detail.schedulingDate),
        icon: LucideIcons.calendarCheck,
      ),
      RowDetailsItem(
        label: AppLocalizations.of(context).commonDuration,
        value: detail.duration > 0
            ? '${detail.duration} min'
            : AppLocalizations.of(context).commonNotDefined,
        icon: LucideIcons.timer,
      ),
    ];
  }

  static List<RowDetailsItem> _buildMemberItems(
    BuildContext context,
    BookingDto detail,
  ) {
    // The signed-in member's RUT and phone live in the decoded session claims,
    // not in every booking projection, so fall back to them when the response's
    // member node omits them. All booking-detail entry points in this member app
    // show the member's own bookings, so the session identity matches.
    final auth = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>()
        : null;
    final rut = detail.memberRut.isNotEmpty
        ? detail.memberRut
        : (auth?.userRut?.trim() ?? '');
    final phone = detail.memberPhone.isNotEmpty
        ? detail.memberPhone
        : (auth?.userMobilePhone?.trim() ?? '');
    final name = detail.memberName.isNotEmpty
        ? detail.memberName
        : (auth?.userName?.trim() ?? '');
    return [
      RowDetailsItem(
        label: 'Name',
        value: name.isEmpty ? AppLocalizations.of(context).commonNoName : name,
        icon: LucideIcons.user,
      ),
      RowDetailsItem(
        label: 'RUT',
        value: rut.isEmpty
            ? AppLocalizations.of(context).commonNotAvailable
            : rut,
        icon: LucideIcons.idCard,
      ),
      RowDetailsItem(
        label: AppLocalizations.of(context).commonPhone,
        value: phone.isEmpty
            ? AppLocalizations.of(context).commonNotAvailable
            : phone,
        icon: LucideIcons.phone,
      ),
    ];
  }

  static List<RowDetailsItem> _buildTrainerItems(
    BuildContext context,
    BookingDto detail,
  ) {
    final items = <RowDetailsItem>[];

    if ((detail.trainerName ?? '').isNotEmpty) {
      items.add(
        RowDetailsItem(
          label: AppLocalizations.of(context).commonTrainer,
          value: detail.trainerName!,
          icon: LucideIcons.dumbbell,
        ),
      );
    }

    if ((detail.disciplineName ?? '').isNotEmpty) {
      items.add(
        RowDetailsItem(
          label: AppLocalizations.of(context).commonDiscipline,
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
          label: AppLocalizations.of(context).commonClass,
          value: detail.serviceName!,
          icon: LucideIcons.dumbbell,
        ),
      );
    }

    final preparation = detail.preparation?.trim() ?? '';
    if (preparation.isNotEmpty) {
      items.add(
        RowDetailsItem(
          label: AppLocalizations.of(context).commonPreparation,
          value: AppLocalizations.of(context).viewPreparation,
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
          AppLocalizations.of(context).commonPreparation,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
          child: SingleChildScrollView(
            child: SelectableText(
              preparationText.isEmpty
                  ? AppLocalizations.of(context).emptyNoPreparation
                  : preparationText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context).commonClose,
              style: TextStyle(color: AppTheme.brandAccentColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
