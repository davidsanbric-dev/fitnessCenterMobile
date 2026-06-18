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
  const AvailableSlotsByDisciplineTrainerUiActions({
    required this.ref,
    required this.uiScopeId,
    required this.filtersController,
    required this.primarySearchController,
    required this.primaryFocusNode,
  });

  final WidgetRef ref;
  final String uiScopeId;
  final AvailableSlotsController filtersController;
  final TextEditingController primarySearchController;
  final FocusNode primaryFocusNode;

  AutoDisposeStateNotifierProvider<
    AvailableSlotsFilterUiNotifier,
    AvailableSlotsFilterUiState
  >
  get _uiProvider => availableSlotsFilterUiProvider(uiScopeId);

  AvailableSlotsFilterUiNotifier get _uiController =>
      ref.read(_uiProvider.notifier);

  AvailableSlotsFilterUiState get _uiState => ref.read(_uiProvider);

  void clearSearchInputs() {
    primarySearchController.clear();
    _uiController.resetTrainerSelection();
  }

  void handleSearchInputChanged() {
    if (primaryFocusNode.hasFocus) {
      _uiController.markFieldTyped(ActiveFilterField.primary);
      _uiController.refreshOverlayAnchor();
    }
  }

  void handlePrimaryFocusChange() {
    if (!primaryFocusNode.hasFocus) {
      return;
    }
    _uiController.focusField(ActiveFilterField.primary);
  }

  void showSheetForField(ActiveFilterField field) {
    primaryFocusNode.requestFocus();
    _uiController.focusField(field);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uiController.refreshOverlayAnchor();
    });
  }

  void hideSheet() {
    final activeField = _uiState.activeField;
    if (activeField == ActiveFilterField.primary) {
      primaryFocusNode.unfocus();
    }
    _uiController.hideSheet();
  }

  void resetFocusAndSheet() {
    primaryFocusNode.unfocus();
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
