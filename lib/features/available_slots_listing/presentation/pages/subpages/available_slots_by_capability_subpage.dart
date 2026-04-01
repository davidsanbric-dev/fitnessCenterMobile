import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/available_slots_controller.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/available_slots_by_capability_table.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/capabilities_group_filter_box.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/capabilities_subgroup_filter_box.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/capabilities_subgroup_items_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvailableSlotsByCapabilityPage extends StatefulWidget {
  const AvailableSlotsByCapabilityPage({
    super.key,
    this.onBack,
    this.isEmbedded = false,
    this.horizontalPadding,
    this.headerSubtitle,
    this.headerSubtitleIcon,
  });

  final VoidCallback? onBack;
  final bool isEmbedded;
  final double? horizontalPadding;
  final String? headerSubtitle;
  final IconData? headerSubtitleIcon;

  @override
  State<AvailableSlotsByCapabilityPage> createState() =>
      _AvailableSlotsByCapabilityPageState();
}

class _AvailableSlotsByCapabilityPageState
    extends State<AvailableSlotsByCapabilityPage> {
  late final AvailableSlotsController _filtersController;
  late final bool _ownsFiltersController;
  CapabilityDto? _selectedGroup;
  CapabilityDto? _selectedSubgroup;
  CapabilityDto? _selectedSubgroupItem;

  @override
  void initState() {
    super.initState();
    _initFiltersController();
    _filtersController.resetCapabilitySubgroup();
    _filtersController.resetCapabilitySubgroupItems();
    _filtersController.resetCapabilityAvailability();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _filtersController.ensureFiltersLoaded(),
    );
  }

  @override
  void dispose() {
    if (_ownsFiltersController) {
      Get.delete<AvailableSlotsController>();
    }
    super.dispose();
  }

  void _initFiltersController() {
    if (Get.isRegistered<AvailableSlotsController>()) {
      _filtersController = Get.find<AvailableSlotsController>();
      _ownsFiltersController = false;
    } else {
      _filtersController = Get.put(AvailableSlotsController());
      _ownsFiltersController = true;
    }
  }

  void _handleGroupSelected(CapabilityDto group) {
    _filtersController.resetAvailabilityView();
    _filtersController.resetCapabilitySubgroup();
    _filtersController.loadCapabilitySubgroupFor(group);
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
    _filtersController.resetAvailabilityView();
    _filtersController.resetCapabilitySubgroupItems();
    setState(() {
      _selectedSubgroup = subgroup;
      _selectedSubgroupItem = null;
    });
    _filtersController.loadCapabilitySubgroupItemsFor(
      group: group,
      subgroup: subgroup,
    );
  }

  void _handleSubgroupItemSelected(CapabilityDto subgroupItem) {
    setState(() {
      _selectedSubgroupItem = subgroupItem;
    });
    _filtersController.loadBookingsByCapability(subgroupItem);
  }

  void _backToGroups() {
    _filtersController.resetCapabilitySubgroup();
    _filtersController.resetCapabilitySubgroupItems();
    _filtersController.resetCapabilityAvailability();
    setState(() {
      _selectedGroup = null;
      _selectedSubgroup = null;
      _selectedSubgroupItem = null;
    });
  }

  void _backToSubgroup() {
    _filtersController.resetCapabilitySubgroupItems();
    _filtersController.resetCapabilityAvailability();
    setState(() {
      _selectedSubgroup = null;
      _selectedSubgroupItem = null;
    });
  }

  void _backToSubgroupItems() {
    _filtersController.resetCapabilityAvailability();
    setState(() {
      _selectedSubgroupItem = null;
    });
  }

  void _handleBack() {
    _filtersController.resetCapabilitySubgroup();
    _filtersController.resetCapabilitySubgroupItems();
    _filtersController.resetCapabilityAvailability();
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

  Future<void> _handleReserveCapabilitySlot(
    AvailableSlotByCapabilityDto slot,
  ) async {
    try {
      await _filtersController.reserveCapabilitySlot(slot);
    } catch (err) {
      if (!mounted) {
        return;
      }
      final message = err.userErrorMessageWith(
        'Could not book this class slot.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
      return;
    }
    if (!mounted) {
      return;
    }

    final when = formatDateTimeLabel(slot.schedulingDate);
    final capability = slot.capabilityDescription.trim().isEmpty
        ? 'Class option'
        : slot.capabilityDescription.trim();
    final location = slot.locationName.trim().isEmpty
        ? 'Club pending confirmation'
        : slot.locationName.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Book $capability on $when at $location.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Obx(() {
      final groups = _filtersController.capabilityGroups.toList(
        growable: false,
      );
      final subgroup = _filtersController.capabilitySubgroup.toList(
        growable: false,
      );
      final subgroupItems = _filtersController.capabilitySubgroupItemsPageRows;
      final capabilitySubgroupItemsPageNumber =
          _filtersController.capabilitySubgroupItemsPageNumber.value;
      final capabilitySubgroupItemsPageSize =
          _filtersController.capabilitySubgroupItemsPageSize.value;
      final capabilitySubgroupItemsTotalItems =
          _filtersController.capabilitySubgroupItemsTotalItems.value;
      final availabilityRows = _filtersController.capabilityBookingsTableRows;
      final capabilityAvailabilityPageNumber =
          _filtersController.capabilityAvailabilityPageNumber.value;
      final capabilityAvailabilityPageSize =
          _filtersController.capabilityAvailabilityPageSize.value;
      final capabilityAvailabilityTotalItems =
          _filtersController.capabilityAvailabilityTotalItems.value;
      final isLoadingFilters = _filtersController.isFiltersLoading.value;
      final hasLoadedCapabilities =
          _filtersController.hasLoadedCapabilityFilters.value;
      final filtersError = _filtersController.filtersError.value;
      final isCapabilitySubgroupItemsLoading =
          _filtersController.isCapabilitySubgroupItemsLoading.value;
      final capabilitySubgroupItemsError =
          _filtersController.capabilitySubgroupItemsError.value;
      final isCapabilityAvailabilityLoading =
          _filtersController.isCapabilityAvailabilityLoading.value;
      final capabilityAvailabilityError =
          _filtersController.capabilityAvailabilityError.value;

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
                      CapabilitiesSubgroupItemsTable(
                        items: subgroupItems,
                        isLoading: isCapabilitySubgroupItemsLoading,
                        errorMessage: capabilitySubgroupItemsError,
                        pageNumber: capabilitySubgroupItemsPageNumber,
                        pageSize: capabilitySubgroupItemsPageSize,
                        totalItems: capabilitySubgroupItemsTotalItems,
                        onPageChanged: _filtersController
                            .setCapabilitySubgroupItemsPageNumber,
                        showPagination: true,
                        filterSummary: [
                          if (_selectedGroup != null)
                            TableFiltersSummaryItemData(
                              label: 'Grupo',
                              value: _selectedGroup?.description ?? '',
                              icon: Icons.category_outlined,
                            ),
                          if (_selectedSubgroup != null)
                            TableFiltersSummaryItemData(
                              label: 'Subgrupo',
                              value: _selectedSubgroup!.description.trim(),
                              icon: Icons.directions_run,
                            ),
                        ],
                        onItemSelected: _handleSubgroupItemSelected,
                      )
                    else if (showAvailabilityStage)
                      AvailableSlotsByCapabilityTable(
                        bookings: availabilityRows,
                        isLoading: isCapabilityAvailabilityLoading,
                        errorMessage: capabilityAvailabilityError,
                        pageNumber: capabilityAvailabilityPageNumber,
                        pageSize: capabilityAvailabilityPageSize,
                        totalItems: capabilityAvailabilityTotalItems,
                        onPageChanged: _filtersController
                            .setCapabilityAvailabilityPageNumber,
                        showPagination: true,
                        filterSummary: [
                          if (_selectedGroup != null)
                            TableFiltersSummaryItemData(
                              label: 'Grupo',
                              value: _selectedGroup?.description ?? '',
                              icon: Icons.category_outlined,
                            ),
                          if (_selectedSubgroup != null)
                            TableFiltersSummaryItemData(
                              label: 'Subgrupo',
                              value: _selectedSubgroup!.description.trim(),
                              icon: Icons.directions_run,
                            ),
                          if (_selectedSubgroupItem != null)
                            TableFiltersSummaryItemData(
                              label: 'Class option',
                              value: _selectedSubgroupItem!.description.trim(),
                              icon: Icons.sports_score_outlined,
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
    });

    if (widget.isEmbedded) {
      return body;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(top: false, child: body),
    );
  }
}
