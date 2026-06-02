import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/location_code_registry.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/booking/booking_state_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/booking/booking_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/update_booking_status_request.dart';

class BookingsApi extends ApiBase {
  BookingsApi() : super();

  static const String _defaultLocationCode = '1';
  static const String _defaultObservation = '';

  Future<List<BookingStateDto>> getBookingStates() async {
    return getDataListAsync<BookingStateDto>(
      url: ApiUrls.staticsUrl,
      requestErrorMessage: 'Error al obtener estados de cita',
      extractItems: _extractBookingStateItems,
      fromJson: BookingStateDto.fromJson,
    );
  }

  Future<BookingDto> getBooking(BookingRequest request) async {
    final bookings = await getDataListAsync<BookingDto>(
      url: '${ApiUrls.bookingsUrl}/${request.bookingId.trim()}',
      requestErrorMessage: 'Error al obtener cita.',
      extractItems: ApiBase.extractSingleItemList,
      queryParameters: {
        'location_code': LocationCodeRegistry.instance.resolve(
          request.locationCode.trim(),
        ),
      },
      fromJson: BookingDto.fromJson,
    );

    return bookings.first;
  }

  Future<void> updateBookingStatus(UpdateBookingStatusRequest request) async {
    await patchAsync<void>(
      url: '${ApiUrls.bookingsUrl}/${request.bookingId.trim()}/status',
      requestBody: <String, dynamic>{
        'booking_status': request.trimmedBookingStatus,
        'location_code': LocationCodeRegistry.instance.resolve(
          request.trimmedLocationCode.isEmpty
              ? _defaultLocationCode
              : request.trimmedLocationCode,
        ),
        'notes': request.trimmedObservation.isEmpty
            ? _defaultObservation
            : request.trimmedObservation,
      },
      requestErrorMessage: 'Error al actualizar estado.',
    );
  }

  List<Map<String, dynamic>> _extractBookingStateItems(dynamic data) {
    dynamic payload = data;
    if (payload is Map) {
      payload = payload['value'] ?? payload['Value'] ?? payload;
    }

    if (payload is Map) {
      final stateBooking =
          payload['booking_statuses'] ?? payload['bookingStatuses'];
      return _collectStateOptionItems(stateBooking);
    }

    return const <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _collectStateOptionItems(dynamic stateBooking) {
    if (stateBooking is Map) {
      final options = <Map<String, dynamic>>[];
      stateBooking.forEach((key, value) {
        final code = key?.toString().trim() ?? '';
        final label = value?.toString().trim() ?? '';
        final resolvedCode = code.isEmpty ? label : code;
        final resolvedLabel = label.isEmpty ? code : label;
        if (resolvedCode.isEmpty && resolvedLabel.isEmpty) return;
        options.add({'code': resolvedCode, 'label': resolvedLabel});
      });
      return options;
    }
    if (stateBooking is List) {
      return stateBooking
          .map((state) => state?.toString().trim() ?? '')
          .where((value) => value.isNotEmpty)
          .map((value) => {'code': value, 'label': value})
          .toList(growable: false);
    }

    return const <Map<String, dynamic>>[];
  }
}
