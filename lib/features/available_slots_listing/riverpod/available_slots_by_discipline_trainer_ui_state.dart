import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:equatable/equatable.dart';

enum ActiveFilterField { primary, location }

class AvailableSlotsFilterUiState extends Equatable {
  const AvailableSlotsFilterUiState({
    this.searchMode = DisciplineSearchMode.discipline,
    this.activeField,
    this.isSheetVisible = false,
    this.sheetSessionId = 0,
    this.primaryHasTypedSinceFocus = false,
    this.locationHasTypedSinceFocus = false,
    this.isLoadingTrainers = false,
    this.trainers = const <String>[],
    this.trainersErrorMessage,
  });

  final DisciplineSearchMode searchMode;
  final ActiveFilterField? activeField;
  final bool isSheetVisible;
  final int sheetSessionId;
  final bool primaryHasTypedSinceFocus;
  final bool locationHasTypedSinceFocus;
  final bool isLoadingTrainers;
  final List<String> trainers;
  final String? trainersErrorMessage;

  String get primaryPlaceholder => searchMode == DisciplineSearchMode.discipline
      ? 'Search for a discipline'
      : 'Search for a trainer';

  bool shouldShowSheet({required bool showAvailabilityTable}) =>
      isSheetVisible && activeField != null && !showAvailabilityTable;

  List<String> optionsForActiveField({
    required List<String> locations,
    required List<String> primaryOptions,
  }) => activeField == ActiveFilterField.location ? locations : primaryOptions;

  String get sheetTitle {
    if (activeField == ActiveFilterField.location) {
      return 'Club';
    }
    return searchMode == DisciplineSearchMode.discipline
        ? 'Disciplines'
        : 'Trainers';
  }

  String filterTextForActiveField({
    required String primaryFilterText,
    required String locationFilterText,
  }) {
    final useTypedFilter = activeField == ActiveFilterField.location
        ? locationHasTypedSinceFocus
        : primaryHasTypedSinceFocus;

    if (!useTypedFilter) {
      return '';
    }

    return activeField == ActiveFilterField.location
        ? locationFilterText
        : primaryFilterText;
  }

  AvailableSlotsFilterUiState copyWith({
    DisciplineSearchMode? searchMode,
    Object? activeField = _activeFieldNotSet,
    bool? isSheetVisible,
    int? sheetSessionId,
    bool? primaryHasTypedSinceFocus,
    bool? locationHasTypedSinceFocus,
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
      locationHasTypedSinceFocus:
          locationHasTypedSinceFocus ?? this.locationHasTypedSinceFocus,
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
    locationHasTypedSinceFocus,
    isLoadingTrainers,
    ...trainers,
    trainersErrorMessage,
  ];
}

const Object _activeFieldNotSet = Object();
const Object _trainersErrorNotSet = Object();
