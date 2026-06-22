import 'dart:async';

import 'package:fitnesscenter_mobile/app/core/shared/widgets/forms/inline_error_text.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/slide_page_switcher.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/loading_spinner.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/ui/snackbar_messenger.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/shared_view_model_host.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/feature.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/state/available_slots_by_discipline_trainer_ui_actions.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/state/available_slots_by_discipline_trainer_ui_notifier.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/state/available_slots_by_discipline_trainer_ui_provider.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/state/available_slots_by_discipline_trainer_ui_state.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';
import 'package:fitnesscenter_mobile/features/class_booking/feature.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/available_slots_consult_button.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/available_slots_dropdown_layout.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/available_slots_dropdown_overlay.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/available_slots_filter_fields.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/available_slots_table.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/book_session_header_reporter.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/discipline_trainer_filter_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvailableSlotsByDisciplineTrainerPage extends ConsumerStatefulWidget {
  const AvailableSlotsByDisciplineTrainerPage({
    super.key,
    this.onBack,
    this.isEmbedded = false,
    this.horizontalPadding,
    this.headerSubtitle,
    this.headerSubtitleIcon,
    this.onHeaderStateChanged,
  });

  final VoidCallback? onBack;
  final bool isEmbedded;
  final double? horizontalPadding;
  final String? headerSubtitle;
  final IconData? headerSubtitleIcon;

  /// When provided, this subpage suppresses its own [PageHeader] and reports its
  /// current stage/back handler up so a host renders a unified page header.
  final BookSessionHeaderReporter? onHeaderStateChanged;

  @override
  ConsumerState<AvailableSlotsByDisciplineTrainerPage> createState() =>
      _AvailableSlotsByDisciplineTrainerPageState();
}

class _AvailableSlotsByDisciplineTrainerPageState
    extends ConsumerState<AvailableSlotsByDisciplineTrainerPage>
    with
        SharedViewModelHost<
          AvailableSlotsByDisciplineTrainerPage,
          AvailableSlotsViewModel
        > {
  late final String _uiScopeId;
  late final TextEditingController _primarySearchController;
  late final FocusNode _primaryFocusNode;
  final GlobalKey _primaryFieldKey = GlobalKey();
  String? _lastObservedFiltersError;

  // Set once a back/exit is underway. While true this (now outgoing) page stops
  // reporting its header state, so the slide-out rebuild can't clobber the
  // destination stage's back handler with this page's stale one — which would
  // otherwise point at controllers this State is about to dispose.
  bool _isHandlingBack = false;

  @override
  AvailableSlotsViewModel createViewModel() =>
      AvailableSlotsListingInjector.getAvailableSlotsViewModel();

  @override
  void initState() {
    super.initState();
    _uiScopeId = identityHashCode(this).toString();
    _primarySearchController = TextEditingController();
    _primaryFocusNode = FocusNode();
    _primarySearchController.addListener(_handleSearchInputChanged);
    _primaryFocusNode.addListener(_handlePrimaryFocusChange);
    acquireViewModel();
    // Surface filter-load failures as a snackbar. Mirrors the previous GetX
    // `ever` worker: fire only when the error transitions to a new value, and
    // show it when that value is non-null.
    _lastObservedFiltersError = viewModel.filtersError;
    viewModel.addListener(_handleFiltersControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(viewModel.ensureFiltersLoaded());
    });
  }

  @override
  void dispose() {
    // Tear down subscriptions before the resources they reference so a late
    // worker/listener callback can never touch a disposed controller.
    viewModel.removeListener(_handleFiltersControllerChanged);
    _primarySearchController.removeListener(_handleSearchInputChanged);
    _primaryFocusNode.removeListener(_handlePrimaryFocusChange);
    _primarySearchController.dispose();
    _primaryFocusNode.dispose();
    releaseViewModel();
    super.dispose();
  }

  void _handleFiltersControllerChanged() {
    final message = viewModel.filtersError;
    if (message == _lastObservedFiltersError) {
      return;
    }
    _lastObservedFiltersError = message;
    if (message == null || !mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, message);
    });
  }

  void _handleSearchInputChanged() {
    _uiActions.handleSearchInputChanged();
  }

  void _handlePrimaryFocusChange() {
    _uiActions.handlePrimaryFocusChange();
  }

  void _handleBack() {
    // A stale invocation (e.g. the host's hoisted header still holding this
    // handler after the page was torn down) must never touch the disposed
    // controllers the action operates on.
    if (!mounted) {
      return;
    }
    _isHandlingBack = true;
    _uiActions.handleBack(onBack: widget.onBack);
  }

  void _handleEditFilters() {
    if (!mounted) {
      return;
    }
    _uiActions.handleEditFiltersPressed();
  }

  Future<void> _handleReserveBooking(AvailableSlotDto slot) async {
    await ClassBookingInjector.getSharedClassBookingViewModel()
        .bookStandardAndNotify(
          context: context,
          slot: slot,
          listingContext: viewModel.lastSubmittedFilters,
          onBooked: () async {
            viewModel.removeBookedAvailabilitySlot(slot);
          },
        );
  }

  void _scheduleHeaderReport(String stageKey, VoidCallback? backHandler) {
    final reporter = widget.onHeaderStateChanged;
    if (reporter == null || _isHandlingBack) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isHandlingBack) {
        return;
      }
      reporter(
        stageKey,
        widget.headerSubtitle,
        widget.headerSubtitleIcon,
        backHandler,
      );
    });
  }

  double _horizontalPaddingForWidth(double width) => width > 600 ? 28.0 : 16.0;

  bool _shouldShowConsultButton(
    bool showAvailabilityTable,
    List<String> primaryOptions,
    String? selectedService,
  ) {
    return !showAvailabilityTable &&
        shouldShowConsultButton(
          selectedService: selectedService,
          primaryController: _primarySearchController,
          primaryOptions: primaryOptions,
        );
  }

  FocusNode? _focusNodeForField(ActiveFilterField? field) {
    if (field == ActiveFilterField.primary) {
      return _primaryFocusNode;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(
      _uiProvider.select((state) => state.trainersErrorMessage),
      (previous, next) {
        if (next == null || next == previous || !mounted) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          showAppSnackBar(context, next);
        });
      },
    );
    final uiState = ref.watch(_uiProvider);
    final uiController = ref.read(_uiProvider.notifier);

    final body = ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final disciplineOptions = viewModel.disciplines.toList(growable: false);
        final trainerOptions = uiState.trainers;
        final primaryOptions =
            uiState.searchMode == DisciplineSearchMode.discipline
            ? disciplineOptions
            : trainerOptions;
        final isLoadingFilters =
            viewModel.isFiltersLoading ||
            (uiState.searchMode == DisciplineSearchMode.trainer &&
                uiState.isLoadingTrainers);
        final hasLoadedFilters = viewModel.hasLoadedFilters;
        final filtersError =
            viewModel.filtersError ??
            (uiState.searchMode == DisciplineSearchMode.trainer
                ? uiState.trainersErrorMessage
                : null);
        final showAvailabilityTable = viewModel.hasSubmittedAvailabilityRequest;
        final headerBackHandler = showAvailabilityTable
            ? _handleEditFilters
            : _handleBack;
        _scheduleHeaderReport(
          showAvailabilityTable ? 'disc:availability' : 'disc:filters',
          headerBackHandler,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                widget.horizontalPadding ??
                _horizontalPaddingForWidth(constraints.maxWidth);
            final shouldShowSheet = uiState.shouldShowSheet(
              showAvailabilityTable: showAvailabilityTable,
            );
            final shouldLiftInputs = shouldShowSheet;
            final showSearchModeFilter = !shouldLiftInputs;
            final showConsultButton = _shouldShowConsultButton(
              showAvailabilityTable,
              primaryOptions,
              '',
            );
            final shouldShowFiltersError =
                !showAvailabilityTable &&
                filtersError != null &&
                !isLoadingFilters;
            final sheetOptions = uiState.optionsForActiveField(
              primaryOptions: primaryOptions,
            );
            final sheetTitle = uiState.sheetTitle;
            final sheetFilterText = uiState.filterTextForActiveField(
              primaryFilterText: _primarySearchController.text,
            );
            final activeFieldKey = _primaryFieldKey;

            // The filters stage (search-mode box + fields) and the availability
            // stage (results table) are the two cards the SlidePageSwitcher
            // slides between, matching the earlier flow transitions.
            final Widget filtersStage = SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    const SizedBox(height: 20),
                    if (showSearchModeFilter)
                      DisciplineTrainerFilterBox(
                        selectedMode: uiState.searchMode,
                        onChanged: _uiActions.handleSearchModeChanged,
                      ),
                    if (isLoadingFilters && !hasLoadedFilters)
                      const LoadingSpinner()
                    else
                      AvailableSlotsFilterFields(
                        primaryController: _primarySearchController,
                        primaryFocusNode: _primaryFocusNode,
                        primaryPlaceholder: uiState.primaryPlaceholder,
                        liftToTop: shouldLiftInputs,
                        showOnlyActiveField: shouldShowSheet,
                        activeFocusNode: _focusNodeForField(
                          uiState.activeField,
                        ),
                        primaryFieldKey: _primaryFieldKey,
                        suppressActiveUnderline: shouldShowSheet,
                        onPrimaryTap: () => _uiActions.showSheetForField(
                          ActiveFilterField.primary,
                        ),
                      ),
                    if (shouldShowFiltersError)
                      InlineErrorText(message: filtersError),
                  ],
                ),
              ),
            );

            final Widget availabilityStage = SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  6,
                  horizontalPadding,
                  0,
                ),
                child: AvailableSlotsTable(
                  controller: viewModel,
                  onEditFilters: _uiActions.handleEditFiltersPressed,
                  onReserveBooking: _handleReserveBooking,
                  showEditFiltersButton: false,
                  showPagination: true,
                ),
              ),
            );

            // Resolve the dropdown geometry against this inner region (not the
            // outer builder) so the overlay stays aligned to the fields even when
            // an inline header sits above the sliding body in standalone hosting.
            final Widget slidingBody = LayoutBuilder(
              builder: (innerContext, innerConstraints) {
                final dropdownLayout = resolveAvailableBookingsDropdownLayout(
                  context: innerContext,
                  constraints: innerConstraints,
                  horizontalPadding: horizontalPadding,
                  shouldShowSheet: shouldShowSheet,
                  activeFieldKey: activeFieldKey,
                );

                return Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    SlidePageSwitcher(
                      depth: showAvailabilityTable ? 1 : 0,
                      stageKey: showAvailabilityTable
                          ? 'availability'
                          : 'filters',
                      child: showAvailabilityTable
                          ? availabilityStage
                          : filtersStage,
                    ),
                    if (showConsultButton)
                      AvailableSlotsConsultButton(
                        horizontalPadding: horizontalPadding,
                        selectedService: '',
                        primaryController: _primarySearchController,
                        searchMode: uiState.searchMode,
                        filtersController: viewModel,
                        onHideSheet: _uiActions.hideSheet,
                        buildParams: () {
                          final primaryValue = _primarySearchController.text
                              .trim();
                          if (primaryValue.isEmpty) {
                            return null;
                          }
                          final trainerId =
                              uiState.searchMode == DisciplineSearchMode.trainer
                              ? uiController.resolveTrainerId(primaryValue)
                              : null;
                          final trainerDisciplineId =
                              uiState.searchMode == DisciplineSearchMode.trainer
                              ? uiController.resolveTrainerDisciplineId(
                                  primaryValue,
                                )
                              : null;
                          if (uiState.searchMode ==
                                  DisciplineSearchMode.trainer &&
                              trainerId == null) {
                            return null;
                          }

                          return MemberAvailabilityParams(
                            serviceLabel: '',
                            primarySelectionLabel: primaryValue,
                            searchMode: uiState.searchMode,
                            trainerId: trainerId,
                            trainerDisciplineId: trainerDisciplineId,
                            trainerDisciplineLabel:
                                uiState.searchMode ==
                                    DisciplineSearchMode.trainer
                                ? uiController.resolveTrainerDisciplineLabel(
                                    primaryValue,
                                  )
                                : null,
                          );
                        },
                      ),
                    Positioned.fill(
                      child: AvailableSlotsDropdownOverlay(
                        isVisible: shouldShowSheet,
                        dropdownOffset: dropdownLayout.offset,
                        dropdownWidth: dropdownLayout.width,
                        maxDropdownHeight: dropdownLayout.maxHeight,
                        title: sheetTitle,
                        options: sheetOptions,
                        filterText: sheetFilterText,
                        onOptionSelected: (value) =>
                            _uiActions.handleOptionSelected(
                              activeField: uiState.activeField,
                              value: value,
                            ),
                        onHide: _uiActions.hideSheet,
                      ),
                    ),
                  ],
                );
              },
            );

            // Standalone/dialog hosting renders its own header; keep it fixed
            // above the sliding body so only the stage cards slide, never the
            // header. Chromeless hosting reports its header up and shows none here.
            if (widget.onHeaderStateChanged == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: 'Book a Session',
                    subtitle: widget.headerSubtitle,
                    subtitleIcon: widget.headerSubtitleIcon,
                    onBackButtonPressed: headerBackHandler,
                  ),
                  Expanded(child: slidingBody),
                ],
              );
            }
            return slidingBody;
          },
        );
      },
    );

    if (widget.isEmbedded) {
      return body;
    }
    return Scaffold(body: SafeArea(top: false, child: body));
  }

  AutoDisposeStateNotifierProvider<
    AvailableSlotsFilterUiNotifier,
    AvailableSlotsFilterUiState
  >
  get _uiProvider => availableSlotsFilterUiProvider(_uiScopeId);

  AvailableSlotsByDisciplineTrainerUiActions get _uiActions =>
      AvailableSlotsByDisciplineTrainerUiActions(
        ref: ref,
        uiScopeId: _uiScopeId,
        filtersController: viewModel,
        primarySearchController: _primarySearchController,
        primaryFocusNode: _primaryFocusNode,
      );
}
