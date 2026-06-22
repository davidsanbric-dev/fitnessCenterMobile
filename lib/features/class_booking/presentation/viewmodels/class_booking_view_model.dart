import 'package:fitnesscenter_mobile/app/core/exceptions/error_message.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';
import 'package:fitnesscenter_mobile/features/class_booking/domain/agenda_refresh_port.dart';
import 'package:fitnesscenter_mobile/features/class_booking/domain/class_booking_repository.dart';
import 'package:flutter/foundation.dart';

class ClassBookingViewModel extends ChangeNotifier {
  ClassBookingViewModel({
    ClassBookingRepository? repository,
    AgendaRefreshPort? agendaRefreshPort,
  }) : _repository = repository ?? (throw ArgumentError.notNull('repository')),
       _agendaRefreshPort =
           agendaRefreshPort ??
           (throw ArgumentError.notNull('agendaRefreshPort'));

  final ClassBookingRepository _repository;
  final AgendaRefreshPort _agendaRefreshPort;

  bool _isStandardBookingInProgress = false;
  bool _isClassTypeBookingInProgress = false;
  String? _standardBookingError;
  String? _classTypeBookingError;

  String? get standardBookingError => _standardBookingError;
  String? get classTypeBookingError => _classTypeBookingError;

  Future<void> bookStandard({
    required AvailableSlotDto slot,
    MemberAvailabilityFilters? listingContext,
  }) {
    return _runBooking(
      isInProgress: _isStandardBookingInProgress,
      setInProgress: (value) => _isStandardBookingInProgress = value,
      setError: (value) => _standardBookingError = value,
      book: () =>
          _repository.bookStandard(slot: slot, listingContext: listingContext),
      failureMessage: 'Could not book the session',
    );
  }

  Future<void> bookByClassType({required AvailableSlotByCapabilityDto slot}) {
    return _runBooking(
      isInProgress: _isClassTypeBookingInProgress,
      setInProgress: (value) => _isClassTypeBookingInProgress = value,
      setError: (value) => _classTypeBookingError = value,
      book: () => _repository.bookByClassType(slot: slot),
      failureMessage: 'Could not book this class slot',
    );
  }

  Future<void> _runBooking({
    required bool isInProgress,
    required ValueChanged<bool> setInProgress,
    required ValueChanged<String?> setError,
    required Future<void> Function() book,
    required String failureMessage,
  }) async {
    if (isInProgress) {
      return;
    }

    setInProgress(true);
    setError(null);
    notifyListeners();

    try {
      await book();
      await _agendaRefreshPort.refreshAgenda();
    } catch (error, stackTrace) {
      final message = error.userErrorMessageWith(failureMessage);
      setError(message);
      if (error is ApiException) {
        rethrow;
      }
      Error.throwWithStackTrace(ApiException(message), stackTrace);
    } finally {
      setInProgress(false);
      notifyListeners();
    }
  }
}
