import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/slide_page_switcher.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/ui/error_banner.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/shared_view_model_host.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/widgets.dart';
import 'package:fitnesscenter_mobile/features/class_booking/feature.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/feature.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/types.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CapabilitiesDirectoryPage extends StatefulWidget {
  const CapabilitiesDirectoryPage({super.key});

  @override
  State<CapabilitiesDirectoryPage> createState() =>
      _CapabilitiesDirectoryPageState();
}

class _CapabilitiesDirectoryPageState extends State<CapabilitiesDirectoryPage>
    with SharedViewModelHost<CapabilitiesDirectoryPage, CapabilitiesViewModel> {
  @override
  CapabilitiesViewModel createViewModel() =>
      FitnessDirectoryInjector.getCapabilitiesViewModel();

  @override
  void initState() {
    super.initState();
    acquireViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.ensureGroupsLoaded();
    });
  }

  @override
  void dispose() {
    releaseViewModel();
    super.dispose();
  }

  Future<void> _handleReserveCapabilitySlot(
    AvailableSlotByCapabilityDto slot,
  ) async {
    await ClassBookingInjector.getSharedClassBookingViewModel()
        .bookByClassTypeAndNotify(
          context: context,
          slot: slot,
          onBooked: () async {
            viewModel.removeBookedAvailabilitySlot(slot);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final stage = viewModel.stage;
        final error = viewModel.error;

        return Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth > 700
                  ? 28.0
                  : 12.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (error != null) ErrorBanner(message: error),
                  Expanded(
                    // Slide horizontally between the class-types stages (group →
                    // subgroup → class type → availability), using the stage's
                    // position in the flow as the navigation depth. Each stage
                    // scrolls on its own so the switcher gets the bounded height
                    // its cards fill.
                    child: SlidePageSwitcher(
                      depth: stage.index,
                      stageKey: stage,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          6,
                          horizontalPadding,
                          24,
                        ),
                        child: _buildStageContent(stage),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStageContent(CapabilitiesViewStage stage) {
    switch (stage) {
      case CapabilitiesViewStage.groupSelection:
        return CapabilitiesGroupFilterBox(
          groups: viewModel.groups,
          isLoading: viewModel.isLoading,
          onGroupSelected: viewModel.loadSubgroupFor,
        );
      case CapabilitiesViewStage.subgroupSelection:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CapabilitiesSubgroupFilterBox(
              subgroup: viewModel.subgroup,
              groupLabel: viewModel.selectedGroup?.description,
              isLoading: viewModel.isLoading,
              onCapabilitySelected: viewModel.loadSubgroupItemsFor,
            ),
          ],
        );
      case CapabilitiesViewStage.subgroupItemsSelection:
        // Class types render as the same card grid used for groups/subgroups.
        return CapabilitiesGroupFilterBox(
          groups: viewModel.subgroupItems,
          isLoading: viewModel.isSubgroupItemsLoading,
          emptyStateMessage:
              viewModel.subgroupItemsError ??
              AppLocalizations.of(context).emptyNoClassTypes,
          title: AppLocalizations.of(context).pickClassType,
          iconData: LucideIcons.dumbbell,
          onGroupSelected: viewModel.loadBookingsForCapability,
        );
      case CapabilitiesViewStage.capabilityAvailability:
        return _buildAvailability();
    }
  }

  Widget _buildAvailability() {
    final selectedGroup = viewModel.selectedGroup;
    final selectedSubgroup = viewModel.selectedSubgroup;
    final selectedCapability = viewModel.selectedCapability;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        if (selectedGroup != null ||
            selectedSubgroup != null ||
            selectedCapability != null)
          const SizedBox(height: 8),
        AvailableSlotsByCapabilityTable(
          bookings: viewModel.capabilityBookingsTableRows,
          isLoading: viewModel.isCapabilityAvailabilityLoading,
          errorMessage: viewModel.capabilityAvailabilityError,
          pageNumber: viewModel.capabilityAvailabilityPageNumber,
          pageSize: viewModel.capabilityAvailabilityPageSize,
          totalItems: viewModel.capabilityAvailabilityTotalItems,
          onPageChanged: viewModel.setCapabilityAvailabilityPageNumber,
          showPagination: true,
          filterSummary: [
            if (selectedGroup != null)
              TableFiltersSummaryItemData(
                label: AppLocalizations.of(context).commonGroup,
                value: selectedGroup.description,
                icon: LucideIcons.tags,
              ),
            if (selectedSubgroup != null)
              TableFiltersSummaryItemData(
                label: AppLocalizations.of(context).commonSubgroup,
                value: selectedSubgroup.description.trim(),
                icon: LucideIcons.user,
              ),
            if (selectedCapability != null)
              TableFiltersSummaryItemData(
                label: AppLocalizations.of(context).classOption,
                value: selectedCapability.description.trim(),
                icon: LucideIcons.trophy,
              ),
          ],
          onReserveBooking: _handleReserveCapabilitySlot,
        ),
      ],
    );
  }
}
