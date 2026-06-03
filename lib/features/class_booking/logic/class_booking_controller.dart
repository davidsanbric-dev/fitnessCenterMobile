import 'dart:async';

import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:portfolio_mobile_app/features/class_booking/domain/agenda_refresh_port.dart';
import 'package:portfolio_mobile_app/features/class_booking/domain/class_booking_actions.dart';
import 'package:portfolio_mobile_app/features/class_booking/domain/class_booking_repository.dart';
import 'package:portfolio_mobile_app/features/class_booking/logic/get_agenda_refresh_port.dart';
import 'package:flutter/foundation.dart';

class ClassBookingController extends ChangeNotifier
    implements ClassBookingActions {
  ClassBookingController({
    ClassBookingRepository? repository,
    AgendaRefreshPort? agendaRefreshPort,
  }) : _repository = repository ?? (throw ArgumentError.notNull('repository')),
       _agendaRefreshPort = agendaRefreshPort ?? GetAgendaRefreshPort();

  final ClassBookingRepository _repository;
  final AgendaRefreshPort _agendaRefreshPort;

  final StreamController<bool> _standardLoadingController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _classTypeLoadingController =
      StreamController<bool>.broadcast();

  bool _isStandardBookingInProgress = false;
  bool _isClassTypeBookingInProgress = false;
  String? _standardBookingError;
  String? _classTypeBookingError;

  Stream<bool> get standardLoadingStream => _standardLoadingController.stream;
  Stream<bool> get classTypeLoadingStream => _classTypeLoadingController.stream;

  @override
  bool get isStandardBookingInProgress => _isStandardBookingInProgress;

  @override
  bool get isClassTypeBookingInProgress => _isClassTypeBookingInProgress;

  @override
  String? get standardBookingError => _standardBookingError;

  @override
  String? get classTypeBookingError => _classTypeBookingError;

  @override
  Future<void> bookStandard({
    required AvailableSlotDto slot,
    MemberAvailabilityFilters? listingContext,
  }) async {
    if (_isStandardBookingInProgress) {
      return;
    }

    _isStandardBookingInProgress = true;
    _standardBookingError = null;
    _standardLoadingController.add(true);
    notifyListeners();

    try {
      await _repository.bookStandard(
        slot: slot,
        listingContext: listingContext,
      );
      await _refreshAgendaIfAvailable();
    } catch (error, stackTrace) {
      final message = error.userErrorMessageWith('Could not book the session');
      _standardBookingError = message;
      if (error is ApiException) {
        rethrow;
      }
      Error.throwWithStackTrace(ApiException(message), stackTrace);
    } finally {
      _isStandardBookingInProgress = false;
      _standardLoadingController.add(false);
      notifyListeners();
    }
  }

  @override
  Future<void> bookByClassType({
    required AvailableSlotByCapabilityDto slot,
  }) async {
    if (_isClassTypeBookingInProgress) {
      return;
    }

    _isClassTypeBookingInProgress = true;
    _classTypeBookingError = null;
    _classTypeLoadingController.add(true);
    notifyListeners();

    try {
      await _repository.bookByClassType(slot: slot);
      await _refreshAgendaIfAvailable();
    } catch (error, stackTrace) {
      final message = error.userErrorMessageWith(
        'Could not book this class slot',
      );
      _classTypeBookingError = message;
      if (error is ApiException) {
        rethrow;
      }
      Error.throwWithStackTrace(ApiException(message), stackTrace);
    } finally {
      _isClassTypeBookingInProgress = false;
      _classTypeLoadingController.add(false);
      notifyListeners();
    }
  }

  Future<void> _refreshAgendaIfAvailable() async {
    await _agendaRefreshPort.refreshAgenda();
  }

  @override
  void dispose() {
    _standardLoadingController.close();
    _classTypeLoadingController.close();
    super.dispose();
  }
}
