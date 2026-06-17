import 'package:portfolio_mobile_app/app/core/services/bookings_navigation_service.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/buttons/create_button.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/slide_page_switcher.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/book_session_flow.dart';
import 'package:portfolio_mobile_app/features/bookings/logic/bookings_controller.dart';
import 'package:portfolio_mobile_app/features/bookings/presentation/widgets/bookings_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  late final BookingsController _controller;
  late final bool _ownsController;
  Worker? _bookFlowWorker;

  // While true, the page swaps the bookings table for the in-page "Book a
  // Session" flow and renders a three-tier header
  // (My Bookings › Book a Session › <stage>).
  bool _showBookFlow = false;

  // Header state reported up by the embedded flow for the current stage.
  String? _flowStageKey;
  String? _flowSecondarySubtitle;
  IconData? _flowSecondarySubtitleIcon;
  VoidCallback? _flowBackHandler;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<BookingsController>()) {
      _controller = Get.find<BookingsController>();
      _ownsController = false;
    } else {
      _controller = Get.put(BookingsController());
      _ownsController = true;
    }
    // The Bookings tab is lazily mounted (Offstage + _visitedIndexes in
    // HomeWrapper), so it may not exist yet when Home calls requestBookFlow().
    // Two paths, mirroring ProfilePage:
    //   1. Page already mounted when the request fires → ever() catches it.
    //   2. Page mounts AFTER the request was set → ever() sees no change;
    //      the post-frame callback handles it by checking the current value.
    final navService = BookingsNavigationService.instance;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _consumePendingBookFlow(),
    );
    _bookFlowWorker = ever<bool>(
      navService.pendingBookFlow,
      (_) => _consumePendingBookFlow(),
    );
  }

  @override
  void dispose() {
    _bookFlowWorker?.dispose();
    if (_ownsController) {
      Get.delete<BookingsController>();
    }
    super.dispose();
  }

  void _consumePendingBookFlow() {
    final navService = BookingsNavigationService.instance;
    if (!navService.pendingBookFlow.value || !mounted) {
      return;
    }
    navService.consume();
    if (!_showBookFlow) {
      _openBookFlow();
    }
  }

  Future<void> _refresh() => _controller.reload();

  void _openBookFlow() {
    setState(() {
      _showBookFlow = true;
      _resetFlowHeaderState();
    });
  }

  void _closeBookFlow() {
    setState(() {
      _showBookFlow = false;
      _resetFlowHeaderState();
    });
    // Refresh so any session booked within the flow appears in the list.
    _controller.reload();
  }

  void _resetFlowHeaderState() {
    _flowStageKey = null;
    _flowSecondarySubtitle = null;
    _flowSecondarySubtitleIcon = null;
    _flowBackHandler = null;
  }

  void _handleFlowHeaderState(
    String stageKey,
    String? secondarySubtitle,
    IconData? secondarySubtitleIcon,
    VoidCallback? backHandler,
  ) {
    if (!mounted || _flowStageKey == stageKey) {
      return;
    }
    setState(() {
      _flowStageKey = stageKey;
      _flowSecondarySubtitle = secondarySubtitle;
      _flowSecondarySubtitleIcon = secondarySubtitleIcon;
      _flowBackHandler = backHandler;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: SlidePageSwitcher(
                depth: _showBookFlow ? 1 : 0,
                child: _showBookFlow
                    ? KeyedSubtree(
                        key: const ValueKey('book-flow'),
                        child: _buildBookFlow(),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('bookings-list'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildBookSessionButton(),
                            Expanded(child: _buildBookingsList()),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (!_showBookFlow) {
      return const PageHeader(title: 'My Bookings');
    }
    return PageHeader(
      title: 'My Bookings',
      subtitle: 'Book a Session',
      secondarySubtitle: _flowSecondarySubtitle,
      secondarySubtitleIcon: _flowSecondarySubtitleIcon,
      onBackButtonPressed: _flowBackHandler ?? _closeBookFlow,
    );
  }

  Widget _buildBookFlow() {
    return BookSessionFlow(
      scrollBottomPadding: 24,
      onExit: _closeBookFlow,
      onHeaderStateChanged: _handleFlowHeaderState,
    );
  }

  Widget _buildBookSessionButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: CreateButton(
        label: 'Book a Session',
        onPressed: _openBookFlow,
        icon: const Icon(LucideIcons.calendarPlus, size: 18),
        alignment: Alignment.centerRight,
        spacing: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildBookingsList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Obx(() {
        final items = _controller.bookingsPageRows;
        final bookingsPageNumber = _controller.bookingsPageNumber.value;
        final bookingsPageSize = _controller.bookingsPageSize.value;
        final bookingsTotalItems = _controller.bookingsTotalItems.value;
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              BookingsTable(
                bookings: items,
                isLoading: _controller.isLoading.value,
                errorMessage: _controller.error.value,
                onViewDetails: _controller.showBookingDetails,
                onConfirmReservation: _controller.confirmReservation,
                onCancelReservation: _controller.cancelReservation,
                onUpdateBookingStatus: _controller.updateBookingStatus,
                pageNumber: bookingsPageNumber,
                pageSize: bookingsPageSize,
                totalItems: bookingsTotalItems,
                onPageChanged: _controller.setBookingsPageNumber,
                showPagination: true,
              ),
            ],
          ),
        );
      }),
    );
  }
}
