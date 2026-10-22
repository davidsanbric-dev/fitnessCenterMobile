import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'dart:async';

import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/shared_view_model_host.dart';
import 'package:fitnesscenter_mobile/features/class_booking/feature.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/feature.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/widgets/available_bookings_by_discipline_table.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/widgets/disciplines_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class DisciplinesDirectoryPage extends StatefulWidget {
  const DisciplinesDirectoryPage({
    super.key,
    required this.controller,
    required this.onShowAvailability,
  });

  final DisciplinesDirectoryViewModel controller;
  final VoidCallback onShowAvailability;

  @override
  State<DisciplinesDirectoryPage> createState() =>
      _DisciplinesDirectoryPageState();
}

class _DisciplinesDirectoryPageState extends State<DisciplinesDirectoryPage> {
  @override
  void initState() {
    super.initState();
    _ensureDisciplinesLoaded();
  }

  void _ensureDisciplinesLoaded() {
    if (widget.controller.disciplines.isEmpty && !widget.controller.isLoading) {
      unawaited(
        widget.controller.loadDisciplines(
          forceRefresh: true,
          preserveResults: true,
        ),
      );
    }
  }

  void _handleDisciplineSelected(
    BuildContext context,
    Map<String, dynamic> row,
  ) {
    final discipline = row['discipline'] as DisciplineDto?;
    if (discipline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).dirSelectDisciplineFailed),
        ),
      );
      return;
    }

    widget.controller.showDisciplineAvailability(discipline);
    widget.onShowAvailability();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isLoading = widget.controller.isLoading;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DisciplinesTable(
                disciplines: widget.controller.disciplinesRows,
                isLoading: isLoading,
                errorMessage: widget.controller.error,
                pageNumber: widget.controller.pageNumber,
                pageSize: widget.controller.pageSize,
                totalItems: widget.controller.totalItems,
                onPageChanged: widget.controller.setPageNumber,
                showPagination: true,
                onDisciplineSelected: (row) =>
                    _handleDisciplineSelected(context, row),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DisciplinesDirectoryStandalonePage extends StatefulWidget {
  const DisciplinesDirectoryStandalonePage({super.key});

  @override
  State<DisciplinesDirectoryStandalonePage> createState() =>
      _DisciplinesDirectoryStandalonePageState();
}

class _DisciplinesDirectoryStandalonePageState
    extends State<DisciplinesDirectoryStandalonePage>
    with
        SharedViewModelHost<
          DisciplinesDirectoryStandalonePage,
          DisciplinesDirectoryViewModel
        > {
  bool _showAvailability = false;

  @override
  DisciplinesDirectoryViewModel createViewModel() =>
      FitnessDirectoryInjector.getDisciplinesDirectoryViewModel();

  @override
  void initState() {
    super.initState();
    acquireViewModel();
  }

  @override
  void dispose() {
    releaseViewModel();
    super.dispose();
  }

  void _handleShowAvailability() {
    if (_showAvailability) {
      return;
    }
    setState(() {
      _showAvailability = true;
    });
  }

  void _handleBack() {
    if (_showAvailability) {
      viewModel.backToResults();
      setState(() {
        _showAvailability = false;
      });
      return;
    }
    Get.back();
  }

  Future<void> _handleReserveBooking(AvailableSlotDto slot) async {
    await ClassBookingInjector.getSharedClassBookingViewModel()
        .bookStandardAndNotify(
          context: context,
          slot: slot,
          onBooked: () async {
            viewModel.removeBookedAvailabilitySlot(slot);
          },
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

  Widget _buildAvailabilityView() {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final selectedDiscipline = viewModel.selectedDiscipline;
        final summary = _buildDisciplineAvailabilitySummary(selectedDiscipline);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: AvailableBookingsByDisciplineTable(
            bookings: viewModel.disciplineAvailabilityRows,
            isLoading: viewModel.isDisciplineAvailabilityLoading,
            errorMessage: viewModel.disciplineAvailabilityError,
            filterSummary: summary,
            onReserveBooking: _handleReserveBooking,
            pageNumber: viewModel.disciplineAvailabilityPageNumber,
            pageSize: viewModel.disciplineAvailabilityPageSize,
            totalItems: viewModel.disciplineAvailabilityTotalItems,
            onPageChanged: viewModel.setDisciplineAvailabilityPageNumber,
            showPagination: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: AppLocalizations.of(context).dirTitle,
              subtitle: AppLocalizations.of(context).commonDisciplines,
              subtitleIcon: LucideIcons.dumbbell,
              onBackButtonPressed: _handleBack,
            ),
            Expanded(
              child: _showAvailability
                  ? _buildAvailabilityView()
                  : DisciplinesDirectoryPage(
                      controller: viewModel,
                      onShowAvailability: _handleShowAvailability,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
