import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/services/trainers_service.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/riverpod/available_slots_by_discipline_trainer_ui_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvailableSlotsFilterUiNotifier
    extends StateNotifier<AvailableSlotsFilterUiState> {
  AvailableSlotsFilterUiNotifier({TrainersService? trainersService})
    : _trainersService = trainersService ?? TrainersService(),
      super(const AvailableSlotsFilterUiState());

  final TrainersService _trainersService;
  TrainersDirectory _trainersDirectory = const TrainersDirectory.empty();
  int _trainersSequence = 0;

  AvailableSlotsFilterUiState get currentState => state;

  Future<void> ensureTrainersLoaded() async {
    if (state.isLoadingTrainers) {
      return;
    }
    if (state.trainers.isNotEmpty && state.trainersErrorMessage == null) {
      return;
    }
    await loadAllTrainers();
  }

  void changeSearchMode(DisciplineSearchMode newMode) {
    if (newMode == state.searchMode) {
      return;
    }
    state = state.copyWith(
      searchMode: newMode,
      activeField: null,
      isSheetVisible: false,
      primaryHasTypedSinceFocus: false,
    );
    resetTrainerSelection();
  }

  void focusField(ActiveFilterField field) {
    if (state.activeField == field && state.isSheetVisible) {
      return;
    }

    state = state.copyWith(
      activeField: field,
      isSheetVisible: true,
      sheetSessionId: state.sheetSessionId + 1,
      primaryHasTypedSinceFocus: field == ActiveFilterField.primary
          ? false
          : state.primaryHasTypedSinceFocus,
    );
  }

  void refreshOverlayAnchor() {
    if (!state.isSheetVisible || state.activeField == null) {
      return;
    }
    state = state.copyWith();
  }

  void markFieldTyped(ActiveFilterField field) {
    if (field == ActiveFilterField.primary &&
        !state.primaryHasTypedSinceFocus) {
      state = state.copyWith(primaryHasTypedSinceFocus: true);
    }
  }

  void hideSheet() {
    if (!state.isSheetVisible && state.activeField == null) {
      return;
    }
    state = state.copyWith(isSheetVisible: false, activeField: null);
  }

  void resetSheet() {
    state = state.copyWith(
      activeField: null,
      isSheetVisible: false,
      primaryHasTypedSinceFocus: false,
    );
  }

  Future<void> loadAllTrainers() async {
    final sequence = ++_trainersSequence;
    state = state.copyWith(
      isLoadingTrainers: true,
      trainers: const <String>[],
      trainersErrorMessage: null,
    );
    _trainersDirectory = const TrainersDirectory.empty();

    try {
      final trainersDirectory = await _trainersService.loadAllTrainers();
      if (!_isCurrent(sequence)) {
        return;
      }

      _trainersDirectory = trainersDirectory;

      state = state.copyWith(
        isLoadingTrainers: false,
        trainers: trainersDirectory.trainers,
        trainersErrorMessage: trainersDirectory.isEmpty
            ? 'No se encontraron profesionales disponibles.'
            : null,
      );
    } catch (err) {
      if (!_isCurrent(sequence)) {
        return;
      }
      _trainersDirectory = const TrainersDirectory.empty();
      state = state.copyWith(
        isLoadingTrainers: false,
        trainers: const <String>[],
        trainersErrorMessage: err.userErrorMessageWith(
          'No se pudieron cargar los profesionales',
        ),
      );
    }
  }

  void resetTrainerSelection() {
    _trainersSequence++;
    _trainersDirectory = const TrainersDirectory.empty();
    state = state.copyWith(
      isLoadingTrainers: false,
      trainers: const <String>[],
      trainersErrorMessage: null,
    );
  }

  String? resolveTrainerId(String label) =>
      _trainersDirectory.resolveTrainerId(label);

  int? resolveTrainerDisciplineId(String label) =>
      _trainersDirectory.resolveTrainerDisciplineId(label);

  String? resolveTrainerDisciplineLabel(String label) =>
      _trainersDirectory.resolveTrainerDisciplineLabel(label);

  bool _isCurrent(int sequence) => sequence == _trainersSequence;
}
