import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'dart:async';

import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/trainer/trainer_directory_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/slide_page_switcher.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/shared_view_model_host.dart';
import 'package:fitnesscenter_mobile/features/class_booking/feature.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/feature.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/types.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/widgets/available_bookings_by_trainer_table.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/widgets/trainer_info_dialog.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/widgets/trainers_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class TrainersDirectoryPage extends StatefulWidget {
  const TrainersDirectoryPage({super.key});

  @override
  State<TrainersDirectoryPage> createState() => _TrainersDirectoryPageState();
}

class _TrainersDirectoryPageState extends State<TrainersDirectoryPage>
    with SharedViewModelHost<TrainersDirectoryPage, TrainersViewModel> {
  @override
  TrainersViewModel createViewModel() =>
      FitnessDirectoryInjector.getTrainersViewModel();

  @override
  void initState() {
    super.initState();
    acquireViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(viewModel.loadAllTrainers());
    });
  }

  @override
  void dispose() {
    releaseViewModel();
    super.dispose();
  }

  void _handleTrainerInfo(Map<String, dynamic> row) {
    final trainer = row['trainer'] as TrainerDirectoryDto?;
    if (trainer == null) {
      _showSnackBar(AppLocalizations.of(context).dirTrainerProfileFailed);
      return;
    }
    unawaited(TrainerInfoDialog.show(context, trainer));
  }

  void _handleTrainerSelected(Map<String, dynamic> row) {
    final trainer = row['trainer'] as TrainerDirectoryDto?;
    if (trainer == null) {
      _showSnackBar(AppLocalizations.of(context).dirSelectTrainerFailed);
      return;
    }
    unawaited(viewModel.showTrainerAvailability(trainer));
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

  void _showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  List<TableFiltersSummaryItemData>? _buildTrainerAvailabilitySummary(
    TrainerDirectoryDto? trainer,
  ) {
    if (trainer == null) {
      return null;
    }
    final items = <TableFiltersSummaryItemData>[];
    final trainerName = trainer.trainerName.trim();
    if (trainerName.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: AppLocalizations.of(context).commonTrainer,
          value: trainerName,
          icon: LucideIcons.user,
        ),
      );
    }
    final discipline = trainer.disciplineName.trim();
    if (discipline.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: AppLocalizations.of(context).commonDiscipline,
          value: discipline,
          icon: LucideIcons.star,
        ),
      );
    }
    final membership = trainer.membershipName.trim();
    if (membership.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: AppLocalizations.of(context).commonPlan,
          value: membership,
          icon: LucideIcons.creditCard,
        ),
      );
    }
    if (items.isEmpty) {
      return null;
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final stage = viewModel.stage;
        final isLoading = viewModel.isLoading;
        final errorMessage = viewModel.error;
        final trainers = viewModel.trainersTableRows;
        final mode = viewModel.trainersMode;
        final availabilityRows = viewModel.trainerAvailabilityRows;
        final availabilityLoading = viewModel.isTrainerAvailabilityLoading;
        final availabilityError = viewModel.trainerAvailabilityError;
        final selectedTrainer = viewModel.selectedTrainer;

        final isAvailability = stage == TrainersViewStage.availability;
        // Slide between the trainers table and a trainer's availability table the
        // same way the directory sections slide: the table list is the root and
        // the availability table sits one level deeper. Keyed by the logical view
        // so a filters→results change keeps the table in place without sliding.
        return SlidePageSwitcher(
          depth: isAvailability ? 1 : 0,
          stageKey: isAvailability ? 'availability' : 'trainers',
          child: isAvailability
              ? _buildAvailabilityView(
                  bookings: availabilityRows,
                  isLoading: availabilityLoading,
                  errorMessage: availabilityError,
                  selectedTrainer: selectedTrainer,
                )
              : _buildTrainersView(
                  stage: stage,
                  trainers: trainers,
                  mode: mode,
                  isLoading: isLoading,
                  errorMessage: errorMessage,
                ),
        );
      },
    );
  }

  Widget _buildTrainersView({
    required TrainersViewStage stage,
    required List<Map<String, dynamic>> trainers,
    required TrainersSearchMode mode,
    required bool isLoading,
    required String? errorMessage,
  }) {
    // Pad the card away from the screen edges so its rounded border breathes,
    // matching the disciplines directory layout.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: TrainersTable(
        trainers: trainers,
        mode: mode,
        isLoading: isLoading,
        errorMessage: errorMessage,
        onTrainerSelected: _handleTrainerSelected,
        onTrainerInfo: _handleTrainerInfo,
        pageNumber: viewModel.trainersPageNumber,
        pageSize: viewModel.trainersPageSize,
        totalItems: viewModel.trainersTotalItems,
        onPageChanged: viewModel.setTrainersPageNumber,
        showPagination: stage == TrainersViewStage.results,
        emptyLabel: AppLocalizations.of(context).emptyNoTrainers,
      ),
    );
  }

  Widget _buildAvailabilityView({
    required List<Map<String, dynamic>> bookings,
    required bool isLoading,
    required String? errorMessage,
    required TrainerDirectoryDto? selectedTrainer,
  }) {
    final summary = _buildTrainerAvailabilitySummary(selectedTrainer);

    return AvailableBookingsByTrainerTable(
      bookings: bookings,
      isLoading: isLoading,
      errorMessage: errorMessage,
      filterSummary: summary,
      onReserveBooking: _handleReserveBooking,
      pageNumber: viewModel.trainerAvailabilityPageNumber,
      pageSize: viewModel.trainerAvailabilityPageSize,
      totalItems: viewModel.trainerAvailabilityTotalItems,
      onPageChanged: viewModel.setTrainerAvailabilityPageNumber,
      showPagination: true,
    );
  }
}

class TrainersDirectoryStandalonePage extends StatefulWidget {
  const TrainersDirectoryStandalonePage({super.key});

  @override
  State<TrainersDirectoryStandalonePage> createState() =>
      _TrainersDirectoryStandalonePageState();
}

class _TrainersDirectoryStandalonePageState
    extends State<TrainersDirectoryStandalonePage> {
  void _handleBack() {
    if (Get.isRegistered<TrainersViewModel>()) {
      final controller = Get.find<TrainersViewModel>();
      if (controller.stage == TrainersViewStage.availability) {
        controller.backToResults();
        return;
      }
    }
    Get.back();
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
              subtitle: AppLocalizations.of(context).commonTrainers,
              subtitleIcon: LucideIcons.user,
              onBackButtonPressed: _handleBack,
            ),
            const Expanded(child: TrainersDirectoryPage()),
          ],
        ),
      ),
    );
  }
}
