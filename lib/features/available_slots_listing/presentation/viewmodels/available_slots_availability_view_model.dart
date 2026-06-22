import 'package:fitnesscenter_mobile/app/core/exceptions/error_message.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_pagination.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/domain/domain.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/viewmodels/available_slots_filters_view_model.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';
import 'package:fitnesscenter_mobile/features/class_booking/feature.dart';

class AvailableSlotsAvailabilityViewModel extends ViewModelBase {
  AvailableSlotsAvailabilityViewModel({
    required this.filtersViewModel,
    required AvailabilityListingRepository repository,
    ClassBookingViewModel? bookingViewModel,
  }) : _repository = repository,
       _bookingViewModel =
           bookingViewModel ??
           ClassBookingInjector.getSharedClassBookingViewModel();

  static const int _defaultAvailabilityPageSize = 6;

  final AvailableSlotsFiltersViewModel filtersViewModel;
  final AvailabilityListingRepository _repository;
  final ClassBookingViewModel _bookingViewModel;

  int _availabilitySequence = 0;

  bool hasSubmittedAvailabilityRequest = false;
  bool isAvailabilityLoading = false;
  String? availabilityError;
  bool isReservingBooking = false;
  String? reserveBookingError;
  final List<AvailableSlotDto> availableSlots = <AvailableSlotDto>[];
  MemberAvailabilityFilters? lastSubmittedFilters;
  int availabilityPageNumber = 1;
  int availabilityPageSize = _defaultAvailabilityPageSize;
  int availabilityTotalItems = 0;

  List<Map<String, dynamic>> get availableSlotsTableRows => sliceTablePage(
    availableSlots
        .map((slot) => slot.toBookingsTableRow())
        .toList(growable: false),
    pageNumber: availabilityPageNumber,
    pageSize: availabilityPageSize,
    defaultPageSize: _defaultAvailabilityPageSize,
  );

  Future<void> consultAvailability(MemberAvailabilityParams params) async {
    hasSubmittedAvailabilityRequest = true;
    availabilityError = null;
    availabilityPageNumber = 1;
    notifyListeners();

    filtersViewModel.resetCapabilityAvailability();

    final filters = filtersViewModel.buildAvailabilityFilters(params);

    if (filters == null) {
      availableSlots.clear();
      _syncAvailabilityPagination();
      availabilityError =
          'Could not parse the selected filters. '
          'Please try again.';
      notifyListeners();
      return;
    }

    final previousFilters = lastSubmittedFilters;
    final isDuplicateRequest =
        isAvailabilityLoading &&
        previousFilters != null &&
        previousFilters.disciplineId == filters.disciplineId &&
        previousFilters.trainerId == filters.trainerId &&
        previousFilters.searchMode == filters.searchMode;
    if (isDuplicateRequest) {
      return;
    }

    lastSubmittedFilters = filters;
    await runLatestLoadOperation<List<AvailableSlotDto>>(
      setLoading: (value) => isAvailabilityLoading = value,
      setError: (value) => availabilityError = value,
      loader: () => _repository.fetchAvailableBookings(filters: filters),
      onSuccess: (slots) {
        availableSlots
          ..clear()
          ..addAll(slots);
        _syncAvailabilityPagination();
      },
      onError: () {
        availableSlots.clear();
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
    final filters = lastSubmittedFilters;
    if (!hasSubmittedAvailabilityRequest || filters == null) {
      return;
    }
    await runLatestLoadOperation<List<AvailableSlotDto>>(
      setLoading: (value) => isAvailabilityLoading = value,
      setError: (value) => availabilityError = value,
      loader: () => _repository.fetchAvailableBookings(filters: filters),
      onSuccess: (slots) {
        availableSlots
          ..clear()
          ..addAll(slots);
        _syncAvailabilityPagination();
      },
      onError: () {
        availableSlots.clear();
        _syncAvailabilityPagination();
      },
      unexpectedErrorMessage: 'Could not load available time slots',
      startSequence: () => ++_availabilitySequence,
      shouldApplyResult: (sequence) => sequence == _availabilitySequence,
    );
  }

  Future<void> reserveBooking(AvailableSlotDto slot) async {
    if (isReservingBooking) {
      return;
    }

    isReservingBooking = true;
    reserveBookingError = null;
    notifyListeners();
    try {
      await _bookingViewModel.bookStandard(
        slot: slot,
        listingContext: lastSubmittedFilters,
      );
      availableSlots.remove(slot);
      _syncAvailabilityPagination();
    } catch (err, stackTrace) {
      final message = err.userErrorMessageWith('Could not book the session');
      reserveBookingError = message;
      if (err is ApiException) {
        rethrow;
      }
      Error.throwWithStackTrace(ApiException(message), stackTrace);
    } finally {
      isReservingBooking = false;
      notifyListeners();
    }
  }

  void resetAvailabilityView() {
    _availabilitySequence++;
    hasSubmittedAvailabilityRequest = false;
    isAvailabilityLoading = false;
    availabilityError = null;
    isReservingBooking = false;
    reserveBookingError = null;
    availableSlots.clear();
    availabilityPageNumber = 1;
    availabilityPageSize = _defaultAvailabilityPageSize;
    _syncAvailabilityPagination();
    lastSubmittedFilters = null;
    filtersViewModel.resetCapabilityAvailability();
  }

  void setAvailabilityPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: availabilityPageNumber,
    value: value,
    setPageNumber: (v) => availabilityPageNumber = v,
    syncPagination: _syncAvailabilityPagination,
  );

  void setAvailabilityPageSize(int value) => applyTablePageSize(
    currentPageSize: availabilityPageSize,
    value: value,
    setPageNumber: (v) => availabilityPageNumber = v,
    setPageSize: (v) => availabilityPageSize = v,
    syncPagination: _syncAvailabilityPagination,
  );

  void removeBookedAvailabilitySlot(AvailableSlotDto slot) {
    availableSlots.remove(slot);
    _syncAvailabilityPagination();
  }

  void _syncAvailabilityPagination() {
    syncTablePaginationValues(
      totalItems: availableSlots.length,
      pageNumber: availabilityPageNumber,
      pageSize: availabilityPageSize,
      defaultPageSize: _defaultAvailabilityPageSize,
      setPageNumber: (v) => availabilityPageNumber = v,
      setPageSize: (v) => availabilityPageSize = v,
      onTotalItemsResolved: (value) => availabilityTotalItems = value,
    );
    notifyListeners();
  }
}
