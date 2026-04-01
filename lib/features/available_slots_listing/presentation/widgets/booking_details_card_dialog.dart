import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/info_card.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/dialogs/row_details_card_dialog.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/ui/snackbar_messenger.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final onlineItems = _buildOnlineItems(context, detail);

    return [
      RowDetailsSection(title: 'General Information', items: generalItems),
      RowDetailsSection(title: 'Member', items: memberItems),
      if (trainerItems.isNotEmpty)
        RowDetailsSection(title: 'Trainer', items: trainerItems),
      if (serviceItems.isNotEmpty)
        RowDetailsSection(title: 'Class', items: serviceItems),
      if (onlineItems.isNotEmpty)
        RowDetailsSection(title: 'Online Session', items: onlineItems),
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
        icon: Icons.flag_outlined,
      ),
      RowDetailsItem(
        label: 'Created At',
        value: formatDateTimeLabel(detail.creationDate),
        icon: Icons.schedule,
      ),
      RowDetailsItem(
        label: 'Scheduled At',
        value: formatDateTimeLabel(detail.schedulingDate),
        icon: Icons.event_available,
      ),
      RowDetailsItem(
        label: 'Duration',
        value: detail.duration > 0 ? '${detail.duration} min' : 'Not defined',
        icon: Icons.timelapse,
      ),
      RowDetailsItem(
        label: 'Club',
        value: locationParts.isEmpty
            ? 'Not available'
            : locationParts.join(' · '),
        icon: Icons.apartment,
      ),
    ];
  }

  static List<RowDetailsItem> _buildMemberItems(BookingDto detail) => [
    RowDetailsItem(
      label: 'Name',
      value: detail.memberName.isEmpty ? 'No name' : detail.memberName,
      icon: Icons.person_outline,
    ),
    RowDetailsItem(
      label: 'RUT',
      value: detail.memberRut.isEmpty ? 'Not available' : detail.memberRut,
      icon: Icons.badge_outlined,
    ),
    RowDetailsItem(
      label: 'Phone',
      value: detail.memberPhone.isEmpty ? 'Not available' : detail.memberPhone,
      icon: Icons.phone_outlined,
    ),
  ];

  static List<RowDetailsItem> _buildTrainerItems(BookingDto detail) {
    final items = <RowDetailsItem>[];

    if ((detail.trainerName ?? '').isNotEmpty) {
      items.add(
        RowDetailsItem(
          label: 'Trainer',
          value: detail.trainerName!,
          icon: Icons.sports,
        ),
      );
    }

    if ((detail.disciplineName ?? '').isNotEmpty) {
      items.add(
        RowDetailsItem(
          label: 'Discipline',
          value: detail.disciplineName!,
          icon: Icons.stars_outlined,
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
          icon: Icons.fitness_center,
        ),
      );
    }

    final preparation = detail.preparation?.trim() ?? '';
    if (preparation.isNotEmpty) {
      items.add(
        RowDetailsItem(
          label: 'Preparation',
          value: 'View Preparation',
          icon: Icons.description_outlined,
          onTap: () => _showPreparationDialog(context, preparation),
        ),
      );
    }

    if (items.isEmpty) {
      return const [];
    }

    return items;
  }

  static List<RowDetailsItem> _buildOnlineItems(
    BuildContext context,
    BookingDto detail,
  ) {
    final onlineUrl = detail.onlineUrl?.trim() ?? '';
    if (detail.isOnline != true || onlineUrl.isEmpty) {
      return const [];
    }

    return [
      RowDetailsItem(
        label: 'Link',
        value: 'Open in browser',
        icon: Icons.videocam_outlined,
        onTap: () => _openOnlineUrl(context, onlineUrl),
      ),
    ];
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

  static Future<void> _openOnlineUrl(
    BuildContext context,
    String onlineUrl,
  ) async {
    final uri = _normalizeOnlineUri(onlineUrl);

    if (uri == null) {
      showAppSnackBar(context, 'The online session link is invalid.');
      return;
    }

    try {
      final launchedExternally = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launchedExternally || !context.mounted) return;

      final launchedWithDefault = await launchUrl(uri);

      if (launchedWithDefault || !context.mounted) return;
      showAppSnackBar(context, 'Could not open the browser.');
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(context, 'Could not open the browser.');
    }
  }

  static Uri? _normalizeOnlineUri(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    final normalized =
        trimmed.startsWith(RegExp(r'https?://', caseSensitive: false))
        ? trimmed
        : 'https://$trimmed';

    final uri = Uri.tryParse(Uri.encodeFull(normalized));
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    return uri;
  }
}
