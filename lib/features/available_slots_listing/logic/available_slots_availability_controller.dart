import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/domain/domain.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/available_slots_filters_controller.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:portfolio_mobile_app/features/class_booking/class_booking.dart';
import 'package:get/get.dart';

class AvailableSlotsAvailabilityController extends ControllerBase {
  AvailableSlotsAvailabilityController({
    required this.filtersController,
    required AvailabilityListingRepository repository,
    ClassBookingController? bookingController,
  }) : _repository = repository,
       _bookingController =
           bookingController ??
           ClassBookingInjector.getSharedClassBookingController();

  static const int _defaultAvailabilityPageSize = 6;

  final AvailableSlotsFiltersController filtersController;
  final AvailabilityListingRepository _repository;
  final ClassBookingController _bookingController;

  int _availabilitySequence = 0;

  final hasSubmittedAvailabilityRequest = false.obs;
  final isAvailabilityLoading = false.obs;
  final availabilityError = RxnString();
  final isReservingBooking = false.obs;
  final reserveBookingError = RxnString();
  final RxList<AvailableSlotDto> availableSlots = <AvailableSlotDto>[].obs;
  final lastSubmittedFilters = Rxn<MemberAvailabilityFilters>();
  final availabilityPageNumber = 1.obs;
  final availabilityPageSize = _defaultAvailabilityPageSize.obs;
  final availabilityTotalItems = 0.obs;

  List<Map<String, dynamic>> get availableSlotsTableRows => sliceTablePage(
    availableSlots
        .toList(growable: false)
        .map((slot) => slot.toBookingsTableRow())
        .toList(growable: false),
    pageNumber: availabilityPageNumber.value,
    pageSize: availabilityPageSize.value,
    defaultPageSize: _defaultAvailabilityPageSize,
  );

  Future<void> consultAvailability(MemberAvailabilityParams params) async {
    hasSubmittedAvailabilityRequest.value = true;
    availabilityError.value = null;
    availabilityPageNumber.value = 1;

    filtersController.resetCapabilityAvailability();

    final filters = filtersController.buildAvailabilityFilters(params);

    if (filters == null) {
      availableSlots.clear();
      _syncAvailabilityPagination();
      availabilityError.value =
          'Could not parse the selected filters. '
          'Please try again.';
      return;
    }

    final previousFilters = lastSubmittedFilters.value;
    final isDuplicateRequest =
        isAvailabilityLoading.value &&
        previousFilters != null &&
        previousFilters.disciplineId == filters.disciplineId &&
        previousFilters.trainerId == filters.trainerId &&
        previousFilters.locationId == filters.locationId &&
        previousFilters.searchMode == filters.searchMode;
    if (isDuplicateRequest) {
      return;
    }

    lastSubmittedFilters.value = filters;
    await runLatestLoadOperation<List<AvailableSlotDto>>(
      isLoading: isAvailabilityLoading,
      error: availabilityError,
      loader: () => _repository.fetchAvailableBookings(filters: filters),
      onSuccess: (slots) {
        availableSlots.assignAll(slots);
        availableSlots.refresh();
        _syncAvailabilityPagination();
      },
      onError: () {
        availableSlots.clear();
        availableSlots.refresh();
        _syncAvailabilityPagination();
      },
      unexpectedErrorMessage: 'Could not load available time slots',
      startSequence: () => ++_availabilitySequence,
      shouldApplyResult: (sequence) => sequence == _availabilitySequence,
    );
  }

  /// Re-runs the last submitted availability query (if any) against the backend.
  /// Triggered when a "slot_updated" push arrives so a member viewing slots sees
  /// a trainer's availability change without re-applying filters by hand.
  Future<void> refreshAvailability() async {
    final filters = lastSubmittedFilters.value;
    if (!hasSubmittedAvailabilityRequest.value || filters == null) {
      return;
    }
    await runLatestLoadOperation<List<AvailableSlotDto>>(
      isLoading: isAvailabilityLoading,
      error: availabilityError,
      loader: () => _repository.fetchAvailableBookings(filters: filters),
      onSuccess: (slots) {
        availableSlots.assignAll(slots);
        availableSlots.refresh();
        _syncAvailabilityPagination();
      },
      onError: () {
        availableSlots.clear();
        availableSlots.refresh();
        _syncAvailabilityPagination();
      },
      unexpectedErrorMessage: 'Could not load available time slots',
      startSequence: () => ++_availabilitySequence,
      shouldApplyResult: (sequence) => sequence == _availabilitySequence,
    );
  }

  Future<void> reserveBooking(AvailableSlotDto slot) async {
    if (isReservingBooking.value) {
      return;
    }

    isReservingBooking.value = true;
    reserveBookingError.value = null;
    try {
      await _bookingController.bookStandard(
        slot: slot,
        listingContext: lastSubmittedFilters.value,
      );
      availableSlots.remove(slot);
      _syncAvailabilityPagination();
    } catch (err, stackTrace) {
      final message = err.userErrorMessageWith('Could not book the session');
      reserveBookingError.value = message;
      if (err is ApiException) {
        rethrow;
      }
      Error.throwWithStackTrace(ApiException(message), stackTrace);
    } finally {
      isReservingBooking.value = false;
    }
  }

  void resetAvailabilityView() {
    _availabilitySequence++;
    hasSubmittedAvailabilityRequest.value = false;
    isAvailabilityLoading.value = false;
    availabilityError.value = null;
    isReservingBooking.value = false;
    reserveBookingError.value = null;
    availableSlots.clear();
    availabilityPageNumber.value = 1;
    availabilityPageSize.value = _defaultAvailabilityPageSize;
    _syncAvailabilityPagination();
    lastSubmittedFilters.value = null;
    filtersController.resetCapabilityAvailability();
  }

  void setAvailabilityPageNumber(int value) => setTablePageNumber(
    pageNumber: availabilityPageNumber,
    value: value,
    syncPagination: _syncAvailabilityPagination,
  );

  void setAvailabilityPageSize(int value) => setTablePageSize(
    pageNumber: availabilityPageNumber,
    pageSize: availabilityPageSize,
    value: value,
    syncPagination: _syncAvailabilityPagination,
  );

  void removeBookedAvailabilitySlot(AvailableSlotDto slot) {
    availableSlots.remove(slot);
    _syncAvailabilityPagination();
  }

  void _syncAvailabilityPagination() {
    syncTablePaginationState(
      totalItems: availableSlots.length,
      pageNumber: availabilityPageNumber,
      pageSize: availabilityPageSize,
      defaultPageSize: _defaultAvailabilityPageSize,
      onTotalItemsResolved: (value) => availabilityTotalItems.value = value,
    );
  }
}
