import 'dart:async';

import 'package:portfolio_mobile_app/features/available_slots_listing/feature.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/riverpod/available_slots_by_discipline_trainer_ui_notifier.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/riverpod/available_slots_by_discipline_trainer_ui_provider.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/riverpod/available_slots_by_discipline_trainer_ui_state.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class AvailableSlotsByDisciplineTrainerUiActions {
  static const int _defaultLocationCode = 1;

  const AvailableSlotsByDisciplineTrainerUiActions({
    required this.ref,
    required this.uiScopeId,
    required this.filtersController,
    required this.primarySearchController,
    required this.locationSearchController,
    required this.primaryFocusNode,
    required this.locationFocusNode,
  });

  final WidgetRef ref;
  final String uiScopeId;
  final AvailableSlotsController filtersController;
  final TextEditingController primarySearchController;
  final TextEditingController locationSearchController;
  final FocusNode primaryFocusNode;
  final FocusNode locationFocusNode;

  AutoDisposeStateNotifierProvider<
    AvailableSlotsFilterUiNotifier,
    AvailableSlotsFilterUiState
  >
  get _uiProvider => availableSlotsFilterUiProvider(uiScopeId);

  AvailableSlotsFilterUiNotifier get _uiController =>
      ref.read(_uiProvider.notifier);

  AvailableSlotsFilterUiState get _uiState => ref.read(_uiProvider);

  void ensureDefaultLocationSelection({bool force = false}) {
    final options = filtersController.locations;
    if (options.isEmpty) {
      return;
    }

    final defaultLocation = filtersController.locationController.locations
        .firstWhere(
          (location) =>
              location.id == _defaultLocationCode &&
              location.name.trim().isNotEmpty,
          orElse: () => const BookingsLocationOption(id: 0, name: ''),
        );
    final normalizedDefault = defaultLocation.name.trim().toLowerCase();
    if (normalizedDefault.isEmpty) {
      return;
    }
    final defaultLabel = options.firstWhere(
      (option) => option.trim().toLowerCase() == normalizedDefault,
      orElse: () => '',
    );
    if (defaultLabel.trim().isEmpty) {
      return;
    }

    final currentValue = locationSearchController.text.trim();
    if (!force && currentValue.isNotEmpty) {
      final normalizedCurrent = currentValue.toLowerCase();
      final hasCurrent = options.any(
        (option) => option.trim().toLowerCase() == normalizedCurrent,
      );
      if (hasCurrent) {
        return;
      }
    }

    locationSearchController.text = defaultLabel;
  }

  void clearSearchInputs() {
    primarySearchController.clear();
    locationSearchController.clear();
    _uiController.resetTrainerSelection();
    ensureDefaultLocationSelection(force: true);
  }

  void handleSearchInputChanged() {
    if (primaryFocusNode.hasFocus) {
      _uiController.markFieldTyped(ActiveFilterField.primary);
      _uiController.refreshOverlayAnchor();
      return;
    }

    if (locationFocusNode.hasFocus) {
      _uiController.markFieldTyped(ActiveFilterField.location);
      _uiController.refreshOverlayAnchor();
    }
  }

  void handlePrimaryFocusChange() {
    if (!primaryFocusNode.hasFocus) {
      return;
    }
    _uiController.focusField(ActiveFilterField.primary);
  }

  void handleLocationFocusChange() {
    if (!locationFocusNode.hasFocus) {
      return;
    }
    _uiController.focusField(ActiveFilterField.location);
  }

  void showSheetForField(ActiveFilterField field) {
    if (field == ActiveFilterField.primary) {
      primaryFocusNode.requestFocus();
    } else {
      locationFocusNode.requestFocus();
    }
    _uiController.focusField(field);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uiController.refreshOverlayAnchor();
    });
  }

  void hideSheet() {
    final activeField = _uiState.activeField;
    if (activeField == ActiveFilterField.primary) {
      primaryFocusNode.unfocus();
    } else if (activeField == ActiveFilterField.location) {
      locationFocusNode.unfocus();
    }
    _uiController.hideSheet();
  }

  void resetFocusAndSheet() {
    primaryFocusNode.unfocus();
    locationFocusNode.unfocus();
    _uiController.resetSheet();
  }

  void handleEditFiltersPressed() {
    filtersController.resetAvailabilityView();
    resetFocusAndSheet();
  }

  void handleSearchModeChanged(DisciplineSearchMode newMode) {
    final currentMode = _uiState.searchMode;
    if (currentMode == newMode) {
      return;
    }
    clearSearchInputs();
    resetFocusAndSheet();
    _uiController.changeSearchMode(newMode);
    if (newMode == DisciplineSearchMode.trainer) {
      unawaited(_uiController.ensureTrainersLoaded());
    }
  }

  void handleOptionSelected({
    required ActiveFilterField? activeField,
    required String value,
  }) {
    if (activeField == ActiveFilterField.primary) {
      primarySearchController.text = value;
    } else if (activeField == ActiveFilterField.location) {
      locationSearchController.text = value;
    }
    hideSheet();
  }

  void handleBack({VoidCallback? onBack}) {
    filtersController.resetAvailabilityView();
    clearSearchInputs();
    filtersController.resetCapabilitySubgroup();
    resetFocusAndSheet();
    if (onBack != null) {
      onBack();
      return;
    }
    Get.back();
  }
}
