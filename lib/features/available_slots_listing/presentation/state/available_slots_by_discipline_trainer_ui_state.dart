import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';
import 'package:equatable/equatable.dart';

enum ActiveFilterField { primary }

class AvailableSlotsFilterUiState extends Equatable {
  const AvailableSlotsFilterUiState({
    this.searchMode = DisciplineSearchMode.discipline,
    this.activeField,
    this.isSheetVisible = false,
    this.sheetSessionId = 0,
    this.primaryHasTypedSinceFocus = false,
    this.isLoadingTrainers = false,
    this.trainers = const <String>[],
    this.trainersErrorMessage,
  });

  final DisciplineSearchMode searchMode;
  final ActiveFilterField? activeField;
  final bool isSheetVisible;
  final int sheetSessionId;
  final bool primaryHasTypedSinceFocus;
  final bool isLoadingTrainers;
  final List<String> trainers;
  final String? trainersErrorMessage;

  String primaryPlaceholder(BuildContext context) =>
      searchMode == DisciplineSearchMode.discipline
      ? AppLocalizations.of(context).searchDisciplineHint
      : AppLocalizations.of(context).searchTrainerHint;

  bool shouldShowSheet({required bool showAvailabilityTable}) =>
      isSheetVisible && activeField != null && !showAvailabilityTable;

  List<String> optionsForActiveField({required List<String> primaryOptions}) =>
      primaryOptions;

  String get sheetTitle {
    return searchMode == DisciplineSearchMode.discipline
        ? 'Disciplines'
        : 'Trainers';
  }

  String filterTextForActiveField({required String primaryFilterText}) {
    if (!primaryHasTypedSinceFocus) {
      return '';
    }

    return primaryFilterText;
  }

  AvailableSlotsFilterUiState copyWith({
    DisciplineSearchMode? searchMode,
    Object? activeField = _activeFieldNotSet,
    bool? isSheetVisible,
    int? sheetSessionId,
    bool? primaryHasTypedSinceFocus,
    bool? isLoadingTrainers,
    List<String>? trainers,
    Object? trainersErrorMessage = _trainersErrorNotSet,
  }) {
    return AvailableSlotsFilterUiState(
      searchMode: searchMode ?? this.searchMode,
      activeField: activeField == _activeFieldNotSet
          ? this.activeField
          : activeField as ActiveFilterField?,
      isSheetVisible: isSheetVisible ?? this.isSheetVisible,
      sheetSessionId: sheetSessionId ?? this.sheetSessionId,
      primaryHasTypedSinceFocus:
          primaryHasTypedSinceFocus ?? this.primaryHasTypedSinceFocus,
      isLoadingTrainers: isLoadingTrainers ?? this.isLoadingTrainers,
      trainers: trainers ?? this.trainers,
      trainersErrorMessage: trainersErrorMessage == _trainersErrorNotSet
          ? this.trainersErrorMessage
          : trainersErrorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    searchMode,
    activeField,
    isSheetVisible,
    sheetSessionId,
    primaryHasTypedSinceFocus,
    isLoadingTrainers,
    ...trainers,
    trainersErrorMessage,
  ];
}

const Object _activeFieldNotSet = Object();
const Object _trainersErrorNotSet = Object();
