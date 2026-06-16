import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/widgets.dart';
import 'package:portfolio_mobile_app/features/class_booking/class_booking.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/feature.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CapabilitiesDirectoryPage extends StatefulWidget {
  const CapabilitiesDirectoryPage({super.key});

  @override
  State<CapabilitiesDirectoryPage> createState() =>
      _CapabilitiesDirectoryPageState();
}

class _CapabilitiesDirectoryPageState extends State<CapabilitiesDirectoryPage> {
  static const double _navButtonsGap = 12.0;
  late final CapabilitiesController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<CapabilitiesController>()) {
      _controller = Get.find<CapabilitiesController>();
      _ownsController = false;
    } else {
      _controller = FitnessDirectoryInjector.getCapabilitiesController();
      _ownsController = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.ensureGroupsLoaded();
    });
  }

  @override
  void dispose() {
    if (_ownsController) {
      Get.delete<CapabilitiesController>();
    }
    super.dispose();
  }

  void _handleGroupSelected(CapabilityDto group) {
    _controller.loadSubgroupFor(group);
  }

  void _handleSubgroupSelected(CapabilityDto subgroup) {
    _controller.loadSubgroupItemsFor(subgroup);
  }

  void _handleSubgroupItemSelected(CapabilityDto subgroupItem) {
    _controller.loadBookingsForCapability(subgroupItem);
  }

  Future<void> _handleReserveCapabilitySlot(
    AvailableSlotByCapabilityDto slot,
  ) async {
    await ClassBookingFlow.bookByClassType(
      context: context,
      controller: ClassBookingInjector.getSharedClassBookingController(),
      slot: slot,
      onBooked: () async {
        _controller.removeBookedAvailabilitySlot(slot);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stage = _controller.stage.value;
      final groups = _controller.groups.toList(growable: false);
      final subgroup = _controller.subgroup.toList(growable: false);
      // Class types render as a card grid (no pagination), so use the full list.
      final subgroupItems = _controller.subgroupItems.toList(growable: false);
      final error = _controller.error.value;
      final isLoading = _controller.isLoading.value;
      final selectedGroup = _controller.selectedGroup.value;
      final selectedSubgroup = _controller.selectedSubgroup.value;
      final selectedSubgroupItem = _controller.selectedCapability.value;
      final isSubgroupItemsLoading = _controller.isSubgroupItemsLoading.value;
      final subgroupItemsError = _controller.subgroupItemsError.value;
      final isCapabilityAvailabilityLoading =
          _controller.isCapabilityAvailabilityLoading.value;
      final capabilityAvailabilityError =
          _controller.capabilityAvailabilityError.value;
      final capabilityAvailabilityPageNumber =
          _controller.capabilityAvailabilityPageNumber.value;
      final capabilityAvailabilityPageSize =
          _controller.capabilityAvailabilityPageSize.value;
      final capabilityAvailabilityTotalItems =
          _controller.capabilityAvailabilityTotalItems.value;
      final availabilityRows = _controller.capabilityBookingsTableRows.toList(
        growable: false,
      );
      final useCompactHeaderGap =
          stage == CapabilitiesViewStage.groupSelection ||
          stage == CapabilitiesViewStage.subgroupSelection ||
          stage == CapabilitiesViewStage.subgroupItemsSelection ||
          stage == CapabilitiesViewStage.capabilityAvailability;

      return Padding(
        padding: EdgeInsets.fromLTRB(6, useCompactHeaderGap ? 6 : 20, 6, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 700 ? 28.0 : 12.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.alertCircle,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: AppTheme.errorMessageEmphasis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      useCompactHeaderGap ? 6 : _navButtonsGap,
                      horizontalPadding,
                      24,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _buildStageContent(
                        stage: stage,
                        groups: groups,
                        subgroup: subgroup,
                        subgroupItems: subgroupItems,
                        selectedGroup: selectedGroup,
                        selectedSubgroup: selectedSubgroup,
                        selectedSubgroupItem: selectedSubgroupItem,
                        availabilityRows: availabilityRows,
                        isLoading: isLoading,
                        subgroupItemsIsLoading: isSubgroupItemsLoading,
                        subgroupItemsError: subgroupItemsError,
                        availabilityIsLoading: isCapabilityAvailabilityLoading,
                        availabilityError: capabilityAvailabilityError,
                        capabilityAvailabilityPageNumber:
                            capabilityAvailabilityPageNumber,
                        capabilityAvailabilityPageSize:
                            capabilityAvailabilityPageSize,
                        capabilityAvailabilityTotalItems:
                            capabilityAvailabilityTotalItems,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildStageContent({
    required CapabilitiesViewStage stage,
    required List<CapabilityDto> groups,
    required List<CapabilityDto> subgroup,
    required List<CapabilityDto> subgroupItems,
    required CapabilityDto? selectedGroup,
    required CapabilityDto? selectedSubgroup,
    required CapabilityDto? selectedSubgroupItem,
    required List<Map<String, dynamic>> availabilityRows,
    required bool isLoading,
    required bool subgroupItemsIsLoading,
    required String? subgroupItemsError,
    required bool availabilityIsLoading,
    required String? availabilityError,
    required int capabilityAvailabilityPageNumber,
    required int capabilityAvailabilityPageSize,
    required int capabilityAvailabilityTotalItems,
  }) {
    switch (stage) {
      case CapabilitiesViewStage.groupSelection:
        return CapabilitiesGroupFilterBox(
          key: const ValueKey('group'),
          groups: groups,
          isLoading: isLoading,
          onGroupSelected: _handleGroupSelected,
        );
      case CapabilitiesViewStage.subgroupSelection:
        return Column(
          key: const ValueKey('subgroup'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CapabilitiesSubgroupFilterBox(
              subgroup: subgroup,
              groupLabel: selectedGroup?.description,
              isLoading: isLoading,
              onCapabilitySelected: _handleSubgroupSelected,
            ),
          ],
        );
      case CapabilitiesViewStage.subgroupItemsSelection:
        // Class types render as the same card grid used for groups/subgroups.
        return CapabilitiesGroupFilterBox(
          key: const ValueKey('subgroupItems'),
          groups: subgroupItems,
          isLoading: subgroupItemsIsLoading,
          emptyStateMessage:
              subgroupItemsError ??
              'No class types available for this subcategory.',
          title: 'Pick a class type',
          iconData: LucideIcons.dumbbell,
          onGroupSelected: _handleSubgroupItemSelected,
        );
      case CapabilitiesViewStage.capabilityAvailability:
        return Column(
          key: const ValueKey('capabilityAvailability'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            if (selectedGroup != null ||
                selectedSubgroup != null ||
                selectedSubgroupItem != null)
              const SizedBox(height: 8),
            AvailableSlotsByCapabilityTable(
              bookings: availabilityRows,
              isLoading: availabilityIsLoading,
              errorMessage: availabilityError,
              pageNumber: capabilityAvailabilityPageNumber,
              pageSize: capabilityAvailabilityPageSize,
              totalItems: capabilityAvailabilityTotalItems,
              onPageChanged: _controller.setCapabilityAvailabilityPageNumber,
              showPagination: true,
              filterSummary: [
                if (selectedGroup != null)
                  TableFiltersSummaryItemData(
                    label: 'Group',
                    value: selectedGroup.description,
                    icon: LucideIcons.tags,
                  ),
                if (selectedSubgroup != null)
                  TableFiltersSummaryItemData(
                    label: 'Subgroup',
                    value: selectedSubgroup.description.trim(),
                    icon: LucideIcons.user,
                  ),
                if (selectedSubgroupItem != null)
                  TableFiltersSummaryItemData(
                    label: 'Class option',
                    value: selectedSubgroupItem.description.trim(),
                    icon: LucideIcons.trophy,
                  ),
              ],
              onReserveBooking: _handleReserveCapabilitySlot,
            ),
          ],
        );
    }
  }
}
