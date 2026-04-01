import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/features/bookings/logic/bookings_controller.dart';
import 'package:portfolio_mobile_app/features/bookings/presentation/widgets/bookings_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  late final BookingsController _controller;
  late final bool _ownsController;

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
  }

  @override
  void dispose() {
    if (_ownsController) {
      Get.delete<BookingsController>();
    }
    super.dispose();
  }

  Future<void> _refresh() => _controller.reload();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(title: 'My Bookings (All Locations)'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Obx(() {
                  final items = _controller.bookingsPageRows;
                  final bookingsPageNumber =
                      _controller.bookingsPageNumber.value;
                  final bookingsPageSize = _controller.bookingsPageSize.value;
                  final bookingsTotalItems =
                      _controller.bookingsTotalItems.value;
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        AgendaTable(
                          bookings: items,
                          isLoading: _controller.isLoading.value,
                          errorMessage: _controller.error.value,
                          onViewDetails: _controller.showBookingDetails,
                          onConfirmReservation: _controller.confirmReservation,
                          onCancelReservation: _controller.cancelReservation,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
