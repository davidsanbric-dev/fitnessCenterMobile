import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'dart:async';

import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/slide_page_switcher.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:fitnesscenter_mobile/features/class_booking/feature.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/feature.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/pages/subpages.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/types.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/widgets/available_bookings_by_discipline_table.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class FitnessDirectoryPage extends StatefulWidget {
  const FitnessDirectoryPage({super.key, this.onHeaderChanged});

  /// When provided, Directory reports its header up instead of rendering it
  /// directly, letting a host (the bottom-nav shell) own a single header that
  /// crossfades between tabs.
  final PageHeaderReporter? onHeaderChanged;

  @override
  State<FitnessDirectoryPage> createState() => _FitnessDirectoryPageState();
}

class _FitnessDirectoryPageState extends State<FitnessDirectoryPage> {
  late final FitnessDirectoryCoordinator _coordinator;

  @override
  void initState() {
    super.initState();
    _coordinator = FitnessDirectoryCoordinator();
  }

  @override
  void dispose() {
    _coordinator.dispose();
    super.dispose();
  }

  Future<void> _handleReserveBooking(AvailableSlotDto slot) async {
    await ClassBookingInjector.getSharedClassBookingViewModel()
        .bookStandardAndNotify(
          context: context,
          slot: slot,
          onBooked: () async {
            _coordinator.removeBookedDisciplineSlot(slot);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _coordinator,
      builder: (context, _) {
        final view = _coordinator.view;
        return Scaffold(
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeaderSlot(
                  config: _resolveHeaderConfig(view),
                  reporter: widget.onHeaderChanged,
                ),
                Expanded(
                  child: SlidePageSwitcher(
                    depth: _coordinator.viewDepth,
                    stageKey: view,
                    child: _buildDirectoryView(view),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PageHeaderConfig _resolveHeaderConfig(FitnessDirectoryView view) {
    final title = AppLocalizations.of(context).dirTitle;
    switch (view) {
      case FitnessDirectoryView.options:
        return PageHeaderConfig(title: title);
      case FitnessDirectoryView.disciplines:
      case FitnessDirectoryView.disciplineAvailability:
        return PageHeaderConfig(
          title: title,
          subtitle: AppLocalizations.of(context).commonDisciplines,
          subtitleIcon: LucideIcons.dumbbell,
          onBackButtonPressed: _coordinator.back,
        );
      case FitnessDirectoryView.capabilities:
        return PageHeaderConfig(
          title: title,
          subtitle: AppLocalizations.of(context).classTypes,
          subtitleIcon: LucideIcons.trophy,
          onBackButtonPressed: _coordinator.back,
        );
      case FitnessDirectoryView.trainers:
        return PageHeaderConfig(
          title: title,
          subtitle: AppLocalizations.of(context).commonTrainers,
          subtitleIcon: LucideIcons.user,
          onBackButtonPressed: _coordinator.back,
        );
      case FitnessDirectoryView.memberships:
        return PageHeaderConfig(
          title: title,
          subtitle: AppLocalizations.of(context).commonPlans,
          subtitleIcon: LucideIcons.creditCard,
          onBackButtonPressed: _coordinator.back,
        );
    }
  }

  Widget _buildDirectoryView(FitnessDirectoryView view) {
    switch (view) {
      case FitnessDirectoryView.capabilities:
        return const CapabilitiesDirectoryPage();
      case FitnessDirectoryView.disciplines:
        return DisciplinesDirectoryPage(
          controller: _coordinator.disciplines,
          onShowAvailability: _coordinator.showDisciplineAvailability,
        );
      case FitnessDirectoryView.disciplineAvailability:
        final disciplines = _coordinator.disciplines;
        final summary = _buildDisciplineAvailabilitySummary(
          disciplines.selectedDiscipline,
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: AvailableBookingsByDisciplineTable(
            bookings: disciplines.disciplineAvailabilityRows,
            isLoading: disciplines.isDisciplineAvailabilityLoading,
            errorMessage: disciplines.disciplineAvailabilityError,
            filterSummary: summary,
            onReserveBooking: _handleReserveBooking,
            pageNumber: disciplines.disciplineAvailabilityPageNumber,
            pageSize: disciplines.disciplineAvailabilityPageSize,
            totalItems: disciplines.disciplineAvailabilityTotalItems,
            onPageChanged: disciplines.setDisciplineAvailabilityPageNumber,
            showPagination: true,
          ),
        );
      case FitnessDirectoryView.memberships:
        final shell = _coordinator.shell;
        return MembershipsDirectoryPage(
          memberships: shell.membershipsRows,
          isLoading: shell.isLoading,
          errorMessage: shell.error,
          pageNumber: shell.membershipsPageNumber,
          pageSize: shell.membershipsPageSize,
          totalItems: shell.membershipsTotalItems,
          onPageChanged: shell.setMembershipsPageNumber,
          showPagination: true,
        );
      case FitnessDirectoryView.trainers:
        return const TrainersDirectoryPage();
      case FitnessDirectoryView.options:
        return _buildOptionsMenu();
    }
  }

  Widget _buildOptionsMenu() {
    final options = <DirectoryOption>[
      DirectoryOption(
        title: AppLocalizations.of(context).commonDisciplines,
        icon: LucideIcons.dumbbell,
        onTap: _coordinator.openDisciplines,
      ),
      DirectoryOption(
        title: AppLocalizations.of(context).classTypes,
        icon: LucideIcons.trophy,
        onTap: _coordinator.openCapabilities,
      ),
      DirectoryOption(
        title: AppLocalizations.of(context).commonTrainers,
        icon: LucideIcons.user,
        onTap: _coordinator.openTrainers,
      ),
      DirectoryOption(
        title: AppLocalizations.of(context).commonPlans,
        icon: LucideIcons.creditCard,
        onTap: _coordinator.openMemberships,
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return ListTile(
          leading: Icon(
            option.icon,
            size: 22,
            color: AppTheme.brandAccentColor(context),
          ),
          title: Text(
            option.title,
            style: AppTheme.listTileTitleStyle(context),
          ),
          onTap: option.onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 10,
          ),
          minVerticalPadding: 10,
        );
      },
      separatorBuilder: (context, _) =>
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
    );
  }

  List<TableFiltersSummaryItemData>? _buildDisciplineAvailabilitySummary(
    DisciplineDto? discipline,
  ) {
    if (discipline == null) {
      return null;
    }
    final items = <TableFiltersSummaryItemData>[];
    final disciplineName = discipline.disciplineName.trim();
    if (disciplineName.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: AppLocalizations.of(context).commonDiscipline,
          value: disciplineName,
          icon: LucideIcons.star,
        ),
      );
    }
    if (items.isEmpty) {
      return null;
    }
    return items;
  }
}
