import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/shared_view_model_host.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/feature.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/book_session_header_reporter.dart';
import 'package:fitnesscenter_mobile/features/class_booking/feature.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/available_slots_by_capability_table.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/capabilities_group_filter_box.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/capabilities_subgroup_filter_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class AvailableSlotsByCapabilityPage extends StatefulWidget {
  const AvailableSlotsByCapabilityPage({
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
  State<AvailableSlotsByCapabilityPage> createState() =>
      _AvailableSlotsByCapabilityPageState();
}

class _AvailableSlotsByCapabilityPageState
    extends State<AvailableSlotsByCapabilityPage>
    with
        SharedViewModelHost<
          AvailableSlotsByCapabilityPage,
          AvailableSlotsViewModel
        > {
  CapabilityDto? _selectedGroup;
  CapabilityDto? _selectedSubgroup;
  CapabilityDto? _selectedSubgroupItem;

  @override
  AvailableSlotsViewModel createViewModel() =>
      AvailableSlotsListingInjector.getAvailableSlotsViewModel();

  @override
  void initState() {
    super.initState();
    acquireViewModel();
    viewModel.resetCapabilitySubgroup();
    viewModel.resetCapabilitySubgroupItems();
    viewModel.resetCapabilityAvailability();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => viewModel.ensureFiltersLoaded(),
    );
  }

  @override
  void dispose() {
    releaseViewModel();
    super.dispose();
  }

  void _handleGroupSelected(CapabilityDto group) {
    viewModel.resetAvailabilityView();
    viewModel.resetCapabilitySubgroup();
    viewModel.loadCapabilitySubgroupFor(group);
    setState(() {
      _selectedGroup = group;
      _selectedSubgroup = null;
      _selectedSubgroupItem = null;
    });
  }

  void _handleSubgroupSelected(CapabilityDto subgroup) {
    final group = _selectedGroup;
    if (group == null) {
      return;
    }
    viewModel.resetAvailabilityView();
    viewModel.resetCapabilitySubgroupItems();
    setState(() {
      _selectedSubgroup = subgroup;
      _selectedSubgroupItem = null;
    });
    viewModel.loadCapabilitySubgroupItemsFor(group: group, subgroup: subgroup);
  }

  void _handleSubgroupItemSelected(CapabilityDto subgroupItem) {
    setState(() {
      _selectedSubgroupItem = subgroupItem;
    });
    viewModel.loadBookingsByCapability(subgroupItem);
  }

  void _backToGroups() {
    viewModel.resetCapabilitySubgroup();
    viewModel.resetCapabilitySubgroupItems();
    viewModel.resetCapabilityAvailability();
    setState(() {
      _selectedGroup = null;
      _selectedSubgroup = null;
      _selectedSubgroupItem = null;
    });
  }

  void _backToSubgroup() {
    viewModel.resetCapabilitySubgroupItems();
    viewModel.resetCapabilityAvailability();
    setState(() {
      _selectedSubgroup = null;
      _selectedSubgroupItem = null;
    });
  }

  void _backToSubgroupItems() {
    viewModel.resetCapabilityAvailability();
    setState(() {
      _selectedSubgroupItem = null;
    });
  }

  void _handleBack() {
    viewModel.resetCapabilitySubgroup();
    viewModel.resetCapabilitySubgroupItems();
    viewModel.resetCapabilityAvailability();
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Get.back();
  }

  VoidCallback? _backHandlerForStage({
    required CapabilityDto? selectedGroup,
    required CapabilityDto? selectedSubgroup,
    required CapabilityDto? selectedSubgroupItem,
  }) {
    if (selectedGroup == null) {
      return _handleBack;
    }
    if (selectedSubgroup == null) {
      return _backToGroups;
    }
    if (selectedSubgroupItem == null) {
      return _backToSubgroup;
    }
    return _backToSubgroupItems;
  }

  String _stageKeyFor({
    required CapabilityDto? selectedGroup,
    required CapabilityDto? selectedSubgroup,
    required CapabilityDto? selectedSubgroupItem,
  }) {
    if (selectedGroup == null) {
      return 'cap:group';
    }
    if (selectedSubgroup == null) {
      return 'cap:subgroup';
    }
    if (selectedSubgroupItem == null) {
      return 'cap:items';
    }
    return 'cap:availability';
  }

  void _scheduleHeaderReport(String stageKey, VoidCallback? backHandler) {
    final reporter = widget.onHeaderStateChanged;
    if (reporter == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
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

  Future<void> _handleReserveCapabilitySlot(
    AvailableSlotByCapabilityDto slot,
  ) async {
    await ClassBookingInjector.getSharedClassBookingViewModel()
        .bookByClassTypeAndNotify(
          context: context,
          slot: slot,
          onBooked: () async {
            viewModel.removeBookedCapabilitySlot(slot);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final body = ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final groups = viewModel.capabilityGroups.toList(growable: false);
        final subgroup = viewModel.capabilitySubgroup.toList(growable: false);
        // Class types render as a card grid (no pagination), so use the full list.
        final subgroupItems = viewModel.capabilitySubgroupItems.toList(
          growable: false,
        );
        final availabilityRows = viewModel.capabilityBookingsTableRows;
        final capabilityAvailabilityPageNumber =
            viewModel.capabilityAvailabilityPageNumber;
        final capabilityAvailabilityPageSize =
            viewModel.capabilityAvailabilityPageSize;
        final capabilityAvailabilityTotalItems =
            viewModel.capabilityAvailabilityTotalItems;
        final isLoadingFilters = viewModel.isFiltersLoading;
        final hasLoadedCapabilities = viewModel.hasLoadedCapabilityFilters;
        final filtersError = viewModel.filtersError;
        final isCapabilitySubgroupItemsLoading =
            viewModel.isCapabilitySubgroupItemsLoading;
        final capabilitySubgroupItemsError =
            viewModel.capabilitySubgroupItemsError;
        final isCapabilityAvailabilityLoading =
            viewModel.isCapabilityAvailabilityLoading;
        final capabilityAvailabilityError =
            viewModel.capabilityAvailabilityError;

        final showGroupStage = _selectedGroup == null;
        final showSubgroupStage =
            _selectedGroup != null && _selectedSubgroup == null;
        final showSubgroupItemsStage =
            _selectedSubgroup != null && _selectedSubgroupItem == null;
        final showAvailabilityStage = _selectedSubgroupItem != null;
        final isSubgroupStageLoading =
            showSubgroupStage && isLoadingFilters && subgroup.isEmpty;
        final backHandler = _backHandlerForStage(
          selectedGroup: _selectedGroup,
          selectedSubgroup: _selectedSubgroup,
          selectedSubgroupItem: _selectedSubgroupItem,
        );
        _scheduleHeaderReport(
          _stageKeyFor(
            selectedGroup: _selectedGroup,
            selectedSubgroup: _selectedSubgroup,
            selectedSubgroupItem: _selectedSubgroupItem,
          ),
          backHandler,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                widget.horizontalPadding ??
                (constraints.maxWidth > 600 ? 28.0 : 16.0);
            final shouldUseCompactTopSpacing =
                showGroupStage ||
                showSubgroupStage ||
                showSubgroupItemsStage ||
                showAvailabilityStage;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.onHeaderStateChanged == null)
                  PageHeader(
                    title: 'Book a Session',
                    subtitle: widget.headerSubtitle,
                    subtitleIcon: widget.headerSubtitleIcon,
                    onBackButtonPressed: backHandler,
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    shouldUseCompactTopSpacing ? 10 : 12,
                    horizontalPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!shouldUseCompactTopSpacing) ...[
                        const SizedBox(height: 12),
                        const SizedBox(height: 20),
                      ],
                      if (showGroupStage)
                        CapabilitiesGroupFilterBox(
                          groups: groups,
                          onGroupSelected: _handleGroupSelected,
                          emptyStateMessage: filtersError,
                          isLoading: isLoadingFilters && !hasLoadedCapabilities,
                        )
                      else if (showSubgroupStage)
                        CapabilitiesSubgroupFilterBox(
                          subgroup: subgroup,
                          groupLabel: _selectedGroup?.description,
                          onCapabilitySelected: _handleSubgroupSelected,
                          emptyStateMessage: filtersError,
                          isLoading: isSubgroupStageLoading,
                        )
                      else if (showSubgroupItemsStage)
                        // Class types render as the same card grid used for
                        // groups/subgroups.
                        CapabilitiesGroupFilterBox(
                          groups: subgroupItems,
                          isLoading: isCapabilitySubgroupItemsLoading,
                          emptyStateMessage:
                              capabilitySubgroupItemsError ??
                              'No class types available for this subcategory.',
                          title: 'Pick a class type',
                          iconData: LucideIcons.dumbbell,
                          onGroupSelected: _handleSubgroupItemSelected,
                        )
                      else if (showAvailabilityStage)
                        AvailableSlotsByCapabilityTable(
                          bookings: availabilityRows,
                          isLoading: isCapabilityAvailabilityLoading,
                          errorMessage: capabilityAvailabilityError,
                          pageNumber: capabilityAvailabilityPageNumber,
                          pageSize: capabilityAvailabilityPageSize,
                          totalItems: capabilityAvailabilityTotalItems,
                          onPageChanged:
                              viewModel.setCapabilityAvailabilityPageNumber,
                          showPagination: true,
                          filterSummary: [
                            if (_selectedGroup != null)
                              TableFiltersSummaryItemData(
                                label: 'Grupo',
                                value: _selectedGroup?.description ?? '',
                                icon: LucideIcons.tags,
                              ),
                            if (_selectedSubgroup != null)
                              TableFiltersSummaryItemData(
                                label: 'Subgrupo',
                                value: _selectedSubgroup!.description.trim(),
                                icon: LucideIcons.activity,
                              ),
                            if (_selectedSubgroupItem != null)
                              TableFiltersSummaryItemData(
                                label: 'Class option',
                                value: _selectedSubgroupItem!.description
                                    .trim(),
                                icon: LucideIcons.trophy,
                              ),
                          ],
                          onReserveBooking: _handleReserveCapabilitySlot,
                        ),
                    ],
                  ),
                ),
              ],
            );
            if (widget.isEmbedded) {
              return content;
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: content,
            );
          },
        );
      },
    );

    if (widget.isEmbedded) {
      return body;
    }
    return Scaffold(body: SafeArea(top: false, child: body));
  }
}
