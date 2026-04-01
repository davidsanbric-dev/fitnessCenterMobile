import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/booking/booking_state_dto.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/booking_service.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/dialogs/assign_row_value_dialog.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/location_controller.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/booking_details_card_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingController extends ControllerBase {
  BookingController({
    BookingService? service,
    LocationController? locationController,
  }) : _service = service ?? BookingService(),
       locationController =
           locationController ??
           (Get.isRegistered<LocationController>()
               ? Get.find<LocationController>()
               : Get.put(LocationController()));

  final BookingService _service;
  final LocationController locationController;

  final currentPage = 1.obs;
  final totalCount = 0.obs;
  final bookings = <BookingDto>[].obs;
  final RxList<BookingStateDto> states = <BookingStateDto>[].obs;
  final RxString selectedState = ''.obs;

  List<Map<String, String>> get tableRows =>
      bookings.map((item) => item.toTableRow()).toList(growable: false);

  bool changeState(String? state) {
    return _updateNormalizedFilter(selectedState, state);
  }

  Future<void> loadStates() async {
    final data = await _service.fetchBookingStates();
    states.assignAll(data);
    if (states.isNotEmpty && selectedState.value.isNotEmpty) {
      final resolved = _resolveStateId(selectedState.value);

      selectedState.value = resolved ?? '';
    }
  }

  void clearBookings() {
    bookings.clear();
  }

  Future<void> showBookingDetails(
    BuildContext context,
    String bookingId,
  ) async {
    final trimmedId = bookingId.trim();

    try {
      final locationCode = _resolveBookingLocationCode(trimmedId);

      final detail = await _service.fetchBooking(
        bookingId: trimmedId,
        locationCode: locationCode,
      );
      if (!context.mounted) return;

      await BookingDetailsCardDialog.show(context, booking: detail);
    } on ApiException catch (error) {
      Get.snackbar('Could not load details', error.message);
    } catch (err) {
      Get.snackbar('Unexpected error', 'Could not show booking: $err');
    }
  }

  Future<void> updateBookingStatus(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    final options = _buildStateOptions();

    final initialValue = _resolveStateOptionId(
      options,
      normReqString(row['bookingStatus']),
    );

    final updatedState = await showAssignRowValueDialog(
      context: context,
      title: 'Update Status',
      fieldLabel: 'Status',
      emptySelectionMessage: 'Select a status',
      confirmLabel: 'Update',
      initialValue: initialValue,
      options: options,
      onSubmit: (value) async {
        try {
          final bookingId = normReqString(row['bookingId']);
          await _service.updateBookingStatus(
            bookingId: bookingId,
            state: value,
            locationCode: _resolveBookingLocationCode(bookingId),
          );
          _applyBookingState(bookingId: bookingId, state: value);
          return null;
        } on ApiException catch (error) {
          return error.message;
        } catch (error) {
          return 'Could not update status: $error';
        }
      },
    );

    if (updatedState != null) {
      Get.snackbar('Status updated', 'Booking changed to $updatedState.');
    }
  }

  int _resolveBookingLocationCode(String bookingId) {
    for (final booking in bookings) {
      if (booking.bookingId == bookingId) {
        return booking.locationId;
      }
    }
    return locationController.selectedLocationId.value;
  }

  void _applyBookingState({required String bookingId, required String state}) {
    final trimmedId = bookingId.trim();
    final trimmedState = state.trim();
    if (trimmedId.isEmpty || trimmedState.isEmpty) return;

    final index = bookings.indexWhere((item) => item.bookingId == trimmedId);
    if (index >= 0) {
      bookings[index] = bookings[index].copyWith(state: trimmedState);
      bookings.refresh();
    }

    final matches = _findStateByValue(trimmedState) != null;
    if (!matches) {
      states.add(BookingStateDto(code: trimmedState, label: trimmedState));
      states.sort(
        (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
    }
  }

  List<AssignRowValueOption> _buildStateOptions() {
    final source = states.isNotEmpty
        ? states.toList(growable: false)
        : bookings
              .map(
                (booking) =>
                    BookingStateDto(code: booking.state, label: booking.state),
              )
              .toList(growable: false);

    return buildOptions<BookingStateDto>(
      source: source,
      idSelector: (state) => state.code,
      labelSelector: (state) => state.label,
      normalizeId: (value) => value.toLowerCase(),
    );
  }

  bool _updateNormalizedFilter(RxString target, String? value) {
    final normalized = normReqString(value);
    if (target.value == normalized) return false;
    target.value = normalized;
    return true;
  }

  BookingStateDto? _findStateByValue(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final state in states) {
      final code = state.code.trim().toLowerCase();
      final label = state.label.trim().toLowerCase();
      if (code == normalized || label == normalized) {
        return state;
      }
    }
    return null;
  }

  String? _resolveStateId(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    final match = _findStateByValue(normalized);
    if (match == null) return normalized;
    return match.code.trim().isNotEmpty
        ? match.code.trim()
        : match.label.trim();
  }

  String? resolveStateId(String value) {
    return _resolveStateId(value);
  }

  String _resolveStateOptionId(
    List<AssignRowValueOption> options,
    String currentValue,
  ) {
    final normalized = currentValue.trim().toLowerCase();
    if (normalized.isNotEmpty) {
      for (final option in options) {
        final optionId = option.id.trim().toLowerCase();
        final optionLabel = option.label.trim().toLowerCase();
        if (optionId == normalized || optionLabel == normalized) {
          return option.id;
        }
      }
    }
    return options.first.id;
  }
}
