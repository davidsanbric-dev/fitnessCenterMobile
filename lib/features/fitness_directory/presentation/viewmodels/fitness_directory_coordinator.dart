import 'package:fitnesscenter_mobile/app/config/app_router.dart';
import 'package:fitnesscenter_mobile/app/config/app_tab.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/feature.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/types.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Page-scoped facade that coordinates the Fitness Directory shell with its
/// three section view-models (disciplines, trainers, class types).
///
/// It owns the lazy creation/disposal of the section view-models, the
/// cross-section navigation intents, and the app-tab reset listener — so the
/// page widget can stay declarative. It aggregates every section's
/// notifications into a single [Listenable], rebuilding the page on any change.
class FitnessDirectoryCoordinator extends ChangeNotifier {
  FitnessDirectoryCoordinator() {
    _shell = FitnessDirectoryInjector.getFitnessDirectoryViewModel();
    final hadDisciplines = Get.isRegistered<DisciplinesDirectoryViewModel>();
    _disciplines = FitnessDirectoryInjector.getDisciplinesDirectoryViewModel();
    _ownsDisciplines = !hadDisciplines;
    _shell.addListener(notifyListeners);
    _disciplines.addListener(notifyListeners);
    _attachNavListener();
  }

  late final FitnessDirectoryViewModel _shell;
  late final DisciplinesDirectoryViewModel _disciplines;
  late final bool _ownsDisciplines;
  bool _ownsTrainers = false;
  bool _ownsCapabilities = false;
  AppRouter? _appRouter;
  Worker? _navWorker;
  // Trainers view-model we are subscribed to so the header reacts to its stage
  // changes; bound lazily once the trainers flow is started.
  TrainersViewModel? _boundTrainers;

  // --- Read accessors the page binds to declaratively -----------------------

  FitnessDirectoryView get view => _shell.view;

  FitnessDirectoryViewModel get shell => _shell;

  DisciplinesDirectoryViewModel get disciplines => _disciplines;

  TrainersViewStage? get trainersStage => Get.isRegistered<TrainersViewModel>()
      ? Get.find<TrainersViewModel>().stage
      : null;

  /// Navigation depth per directory view, so the slide switcher knows which way
  /// to animate: the options menu is the root, each section sits one level in,
  /// and a discipline's availability table sits one level deeper still.
  int get viewDepth {
    switch (_shell.view) {
      case FitnessDirectoryView.options:
        return 0;
      case FitnessDirectoryView.disciplineAvailability:
        return 2;
      case FitnessDirectoryView.disciplines:
      case FitnessDirectoryView.capabilities:
      case FitnessDirectoryView.trainers:
      case FitnessDirectoryView.memberships:
        return 1;
    }
  }

  // --- Navigation intents ---------------------------------------------------

  void openDisciplines() {
    _shell.showDisciplines();
    _disciplines.loadDisciplines();
  }

  void openCapabilities() {
    _ensureCapabilities();
    _shell.showCapabilities();
  }

  void openTrainers() {
    _ensureTrainers();
    _shell.showTrainers();
  }

  void openMemberships() => _shell.loadMemberships();

  void showDisciplineAvailability() => _shell.showDisciplineAvailabilityView();

  void removeBookedDisciplineSlot(AvailableSlotDto slot) =>
      _disciplines.removeBookedAvailabilitySlot(slot);

  /// Context-aware back navigation: dispatches to the right section based on the
  /// current view (and, within trainers/class types, the section's own stage).
  void back() {
    switch (_shell.view) {
      case FitnessDirectoryView.options:
        return;
      case FitnessDirectoryView.disciplines:
        showDirectoryOptions();
        return;
      case FitnessDirectoryView.disciplineAvailability:
        _disciplines.backToResults();
        _shell.showDisciplines();
        return;
      case FitnessDirectoryView.capabilities:
        _backFromCapabilities();
        return;
      case FitnessDirectoryView.trainers:
        if (trainersStage == TrainersViewStage.availability) {
          Get.find<TrainersViewModel>().backToResults();
        } else {
          showDirectoryOptions();
        }
        return;
      case FitnessDirectoryView.memberships:
        showDirectoryOptions();
        return;
    }
  }

  void showDirectoryOptions() {
    _disciplines.prepareDirectoryOptions();
    if (Get.isRegistered<TrainersViewModel>()) {
      Get.find<TrainersViewModel>().resetToInitialState();
    }
    if (Get.isRegistered<CapabilitiesViewModel>()) {
      Get.find<CapabilitiesViewModel>().backToGroups();
    }
    _shell.showDirectoryOptions();
  }

  // --- Internals ------------------------------------------------------------

  void _backFromCapabilities() {
    if (!Get.isRegistered<CapabilitiesViewModel>()) {
      showDirectoryOptions();
      return;
    }
    final capabilities = Get.find<CapabilitiesViewModel>();
    switch (capabilities.stage) {
      case CapabilitiesViewStage.groupSelection:
        showDirectoryOptions();
        return;
      case CapabilitiesViewStage.subgroupSelection:
        capabilities.backToGroups();
        return;
      case CapabilitiesViewStage.subgroupItemsSelection:
        capabilities.backToSubgroup();
        return;
      case CapabilitiesViewStage.capabilityAvailability:
        capabilities.backToSubgroupItems();
        return;
    }
  }

  void _ensureTrainers() {
    if (!Get.isRegistered<TrainersViewModel>()) {
      FitnessDirectoryInjector.getTrainersViewModel();
      _ownsTrainers = true;
    }
    final controller = Get.find<TrainersViewModel>();
    if (identical(_boundTrainers, controller)) {
      return;
    }
    _boundTrainers?.removeListener(notifyListeners);
    _boundTrainers = controller;
    controller.addListener(notifyListeners);
  }

  void _ensureCapabilities() {
    if (Get.isRegistered<CapabilitiesViewModel>()) {
      return;
    }
    FitnessDirectoryInjector.getCapabilitiesViewModel();
    _ownsCapabilities = true;
  }

  void _attachNavListener() {
    if (!Get.isRegistered<AppRouter>()) {
      return;
    }
    _appRouter = Get.find<AppRouter>();
    _navWorker = ever<AppTab>(_appRouter!.current, (tab) {
      if (tab == AppTab.fitnessDirectory) {
        return;
      }
      _resetSections();
    });
  }

  void _resetSections() {
    _shell.resetToInitialState();
    if (Get.isRegistered<TrainersViewModel>()) {
      Get.find<TrainersViewModel>().resetToInitialState();
    }
    if (Get.isRegistered<CapabilitiesViewModel>()) {
      Get.find<CapabilitiesViewModel>().backToGroups();
    }
    if (Get.isRegistered<DisciplinesDirectoryViewModel>()) {
      _disciplines.resetToInitialState();
    }
  }

  @override
  void dispose() {
    _navWorker?.dispose();
    _shell.removeListener(notifyListeners);
    _disciplines.removeListener(notifyListeners);
    _boundTrainers?.removeListener(notifyListeners);
    if (_ownsCapabilities && Get.isRegistered<CapabilitiesViewModel>()) {
      Get.delete<CapabilitiesViewModel>();
    }
    if (_ownsTrainers && Get.isRegistered<TrainersViewModel>()) {
      Get.delete<TrainersViewModel>();
    }
    if (_ownsDisciplines) {
      Get.delete<DisciplinesDirectoryViewModel>();
    }
    super.dispose();
  }
}
