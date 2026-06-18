import 'dart:async';

import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainer_directory_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:portfolio_mobile_app/features/class_booking/class_booking.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/feature.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/widgets/available_bookings_by_trainer_table.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/widgets/trainer_info_dialog.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/widgets/trainers_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class TrainersDirectoryPage extends StatefulWidget {
  const TrainersDirectoryPage({super.key});

  @override
  State<TrainersDirectoryPage> createState() => _TrainersDirectoryPageState();
}

class _TrainersDirectoryPageState extends State<TrainersDirectoryPage> {
  late final TrainersController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<TrainersController>()) {
      _controller = Get.find<TrainersController>();
      _ownsController = false;
    } else {
      _controller = FitnessDirectoryInjector.getTrainersController();
      _ownsController = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_controller.loadAllTrainers());
    });
  }

  @override
  void dispose() {
    if (_ownsController) {
      Get.delete<TrainersController>();
    }
    super.dispose();
  }

  void _handleTrainerInfo(Map<String, dynamic> row) {
    final trainer = row['trainer'] as TrainerDirectoryDto?;
    if (trainer == null) {
      _showSnackBar('Could not open the trainer profile.');
      return;
    }
    unawaited(TrainerInfoDialog.show(context, trainer));
  }

  void _handleTrainerSelected(Map<String, dynamic> row) {
    final trainer = row['trainer'] as TrainerDirectoryDto?;
    if (trainer == null) {
      _showSnackBar('Could not select the trainer.');
      return;
    }
    final locationId = trainer.locationId;
    if (locationId <= 0) {
      _showSnackBar('This trainer has no club assigned.');
      return;
    }
    unawaited(
      _controller.showTrainerAvailability(trainer, locationId: locationId),
    );
  }

  Future<void> _handleReserveBooking(AvailableSlotDto slot) async {
    await ClassBookingFlow.bookStandard(
      context: context,
      controller: ClassBookingInjector.getSharedClassBookingController(),
      slot: slot,
      onBooked: () async {
        _controller.removeBookedAvailabilitySlot(slot);
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
          label: 'Trainer',
          value: trainerName,
          icon: LucideIcons.user,
        ),
      );
    }
    final discipline = trainer.disciplineName.trim();
    if (discipline.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Discipline',
          value: discipline,
          icon: LucideIcons.star,
        ),
      );
    }
    final membership = trainer.membershipName.trim();
    if (membership.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Membership plan',
          value: membership,
          icon: LucideIcons.creditCard,
        ),
      );
    }
    final locationLabel = trainer.locationName.trim();
    if (locationLabel.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Club',
          value: locationLabel,
          icon: LucideIcons.building2,
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
    return Obx(() {
      final stage = _controller.stage.value;
      final isLoading = _controller.isLoading.value;
      final errorMessage = _controller.error.value;
      final trainers = _controller.trainersTableRows;
      final mode = _controller.trainersMode.value;
      final availabilityRows = _controller.trainerAvailabilityRows;
      final availabilityLoading =
          _controller.isTrainerAvailabilityLoading.value;
      final availabilityError = _controller.trainerAvailabilityError.value;
      final selectedTrainer = _controller.selectedTrainer.value;

      if (stage == TrainersViewStage.availability) {
        return _buildAvailabilityView(
          bookings: availabilityRows,
          isLoading: availabilityLoading,
          errorMessage: availabilityError,
          selectedTrainer: selectedTrainer,
        );
      }
      return _buildTrainersView(
        stage: stage,
        trainers: trainers,
        mode: mode,
        isLoading: isLoading,
        errorMessage: errorMessage,
      );
    });
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
        pageNumber: _controller.trainersPageNumber.value,
        pageSize: _controller.trainersPageSize.value,
        totalItems: _controller.trainersTotalItems.value,
        onPageChanged: _controller.setTrainersPageNumber,
        showPagination: stage == TrainersViewStage.results,
        emptyLabel: 'No trainers available.',
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
      pageNumber: _controller.trainerAvailabilityPageNumber.value,
      pageSize: _controller.trainerAvailabilityPageSize.value,
      totalItems: _controller.trainerAvailabilityTotalItems.value,
      onPageChanged: _controller.setTrainerAvailabilityPageNumber,
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
    if (Get.isRegistered<TrainersController>()) {
      final controller = Get.find<TrainersController>();
      if (controller.stage.value == TrainersViewStage.availability) {
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
              title: 'Fitness Directory',
              subtitle: 'Trainers',
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
