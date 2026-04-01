import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/inline_error_text.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/loading_spinner.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/ui/snackbar_messenger.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/available_slots_controller.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/available_slots_for_online_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvailableSlotsForOnlineSubPage extends StatefulWidget {
  const AvailableSlotsForOnlineSubPage({
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
  State<AvailableSlotsForOnlineSubPage> createState() =>
      _AvailableSlotsForOnlineSubPageState();
}

class _AvailableSlotsForOnlineSubPageState
    extends State<AvailableSlotsForOnlineSubPage> {
  late final AvailableSlotsController _controller;
  late final String _controllerTag;
  Worker? _locationsWorker;
  Worker? _filtersErrorWorker;
  String? _selectedDiscipline;
  String? _selectedLocationLabel;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'online-${identityHashCode(this)}';
    _initController();
    _controller.resetAvailabilityView();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.ensureFiltersLoaded(),
    );
  }

  @override
  void dispose() {
    _locationsWorker?.dispose();
    _filtersErrorWorker?.dispose();
    Get.delete<AvailableSlotsController>(tag: _controllerTag);
    super.dispose();
  }

  void _initController() {
    _controller = Get.put(AvailableSlotsController(), tag: _controllerTag);

    _locationsWorker = ever<List<String>>(
      _controller.locations,
      (_) => _ensureDefaultLocationSelection(),
    );

    _filtersErrorWorker = ever<String?>(_controller.filtersError, (message) {
      if (message == null || !mounted) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        showAppSnackBar(context, message);
      });
    });
  }

  void _ensureDefaultLocationSelection({bool force = false}) {
    final current = _selectedLocationLabel?.trim() ?? '';
    if (current.isEmpty) {
      return;
    }
    final options = _controller.locations;
    final normalizedCurrent = current.toLowerCase();
    final hasCurrent = options.any(
      (option) => option.trim().toLowerCase() == normalizedCurrent,
    );
    if (hasCurrent && !force) {
      return;
    }
    setState(() {
      _selectedLocationLabel = null;
    });
  }

  void _handleDisciplineSelected(String? value) {
    final label = value?.trim() ?? '';
    if (label.isEmpty) {
      setState(() {
        _selectedDiscipline = null;
      });
      _controller.resetAvailabilityView();
      return;
    }

    if (label == _selectedDiscipline) {
      return;
    }

    setState(() {
      _selectedDiscipline = label;
    });

    _controller.resetAvailabilityView();
    _consultAvailability(label);
  }

  Future<void> _consultAvailability(String disciplineLabel) async {
    final locationLabel = _selectedLocationLabel?.trim() ?? '';

    final params = MemberAvailabilityParams(
      serviceLabel: '',
      primarySelectionLabel: disciplineLabel,
      locationLabel: locationLabel,
      searchMode: DisciplineSearchMode.discipline,
      isOnline: true,
    );

    await _controller.consultAvailability(params);

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _handleBack() {
    _controller.resetAvailabilityView();
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Get.back();
  }

  Future<void> _handleReserveBooking(AvailableSlotDto slot) async {
    try {
      await _controller.reserveBooking(slot, online: '1');
      if (!mounted) return;

      final when = formatDateTimeLabel(slot.schedulingDate);
      showAppSnackBar(context, 'Session booked for $when.');
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        _controller.reserveBookingError.value ?? 'Could not book the session.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Obx(() {
      final disciplines = _controller.disciplines.toList(growable: false);
      final isLoadingFilters = _controller.isFiltersLoading.value;
      final hasLoadedFilters = _controller.hasLoadedFilters.value;
      final filtersError = _controller.filtersError.value;
      final availabilityPageNumber = _controller.availabilityPageNumber.value;
      final availabilityPageSize = _controller.availabilityPageSize.value;
      final availabilityTotalItems = _controller.availabilityTotalItems.value;

      return LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              widget.horizontalPadding ??
              (constraints.maxWidth > 600 ? 28.0 : 16.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: widget.isEmbedded
                      ? 'Book a Session'
                      : 'Online Sessions',
                  subtitle: widget.headerSubtitle,
                  subtitleIcon: widget.headerSubtitleIcon,
                  onBackButtonPressed: _handleBack,
                ),
                Padding(
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
                      if (isLoadingFilters && !hasLoadedFilters)
                        const LoadingSpinner()
                      else
                        AvailableSlotsForOnlineTable(
                          key: ValueKey(
                            'online-table-'
                            '${_controller.isAvailabilityLoading.value}-'
                            '${_controller.availableSlots.length}-'
                            '${_controller.availabilityError.value ?? ''}',
                          ),
                          bookings: _controller.availableSlots.toList(
                            growable: false,
                          ),
                          disciplineOptions: disciplines,
                          selectedDiscipline: _selectedDiscipline,
                          onDisciplineSelected: _handleDisciplineSelected,
                          isLoading: _controller.isAvailabilityLoading.value,
                          errorMessage: _controller.availabilityError.value,
                          pageNumber: availabilityPageNumber,
                          pageSize: availabilityPageSize,
                          totalItems: availabilityTotalItems,
                          onPageChanged: _controller.setAvailabilityPageNumber,
                          showPagination: true,
                          onReserveBooking: _handleReserveBooking,
                        ),
                      if (filtersError != null && !isLoadingFilters)
                        InlineErrorText(message: filtersError),
                    ],
                  ),
                ),
              ],
            ),
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
