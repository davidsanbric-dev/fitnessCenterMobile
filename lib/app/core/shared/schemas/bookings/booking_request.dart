import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class BookingRequest {
  const BookingRequest({
    this.memberId,
    this.startDate,
    this.endDate,
    this.locationCode,
    this.bookingStatus,
    this.isOnline,
    this.disciplineId,
    this.trainerId,
  });

  final String? memberId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? locationCode;
  final String? bookingStatus;
  final String? isOnline;
  final String? disciplineId;
  final String? trainerId;

  static DateTime _defaultStartDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _defaultEndDate(DateTime baseStartDate) =>
      baseStartDate.add(const Duration(days: 14));
  static const String _fallbackMemberId = '20.657.720-7';
  static const String _defaultLocationCode = '1';
  static const String _defaultBookingStatus = '';
  static const String _defaultDisciplineId = '0';
  static const String _defaultTrainerId = '0';
  static final AuthSessionCache _sessionCache = AuthSessionCache();

  Future<Map<String, String>> toQueryParameters({
    DateTime? defaultStartDate,
    DateTime? defaultEndDate,
    String? defaultMemberId,
    String? defaultLocationCode,
    String? defaultBookingStatus,
    String? defaultDisciplineId,
    String? defaultTrainerId,
    String? defaultIsOnline,
  }) async {
    final resolvedStartDate =
        (startDate ?? defaultStartDate ?? _defaultStartDate()).toLocal();
    final resolvedEndDate =
        (endDate ?? defaultEndDate ?? _defaultEndDate(resolvedStartDate))
            .toLocal();
    if (resolvedEndDate.isBefore(resolvedStartDate)) {
      throw const ApiException('End date must be later than start date.');
    }

    final resolvedDefaultMemberId =
        normalizeMemberId(defaultMemberId) ??
        await _resolveDefaultMemberIdFromSession();
    final resolvedMemberId =
        normalizeMemberId(memberId) ?? resolvedDefaultMemberId;
    final resolvedLocationCode =
        normOptString(locationCode) ??
        defaultLocationCode ??
        _defaultLocationCode;
    final resolvedStatus =
        normOptString(bookingStatus) ??
        defaultBookingStatus ??
        _defaultBookingStatus;
    final resolvedOnline = normOptString(isOnline) ?? defaultIsOnline ?? '';
    final resolvedDiscipline =
        normOptString(disciplineId) ??
        defaultDisciplineId ??
        _defaultDisciplineId;
    final resolvedTrainer =
        normOptString(trainerId) ?? defaultTrainerId ?? _defaultTrainerId;

    return <String, String>{
      'startDate': formatDate(resolvedStartDate),
      'endDate': formatDate(resolvedEndDate),
      'locationCode': resolvedLocationCode,
      'bookingStatus': resolvedStatus,
      'memberId': resolvedMemberId,
      'isOnline': resolvedOnline,
      'disciplineId': resolvedDiscipline,
      'trainerId': resolvedTrainer,
    };
  }

  static Future<String> _resolveDefaultMemberIdFromSession() async {
    final sessionUser = await _sessionCache.getUser();
    final sessionMemberId = _extractSessionMemberId(sessionUser);
    return normalizeMemberId(sessionMemberId) ?? _fallbackMemberId;
  }

  static String? _extractSessionMemberId(Map<String, dynamic>? sessionUser) {
    if (sessionUser == null || sessionUser.isEmpty) {
      return null;
    }

    return normOptString(sessionUser['memberId']);
  }

  BookingRequest copyWith({
    String? memberId,
    DateTime? startDate,
    DateTime? endDate,
    String? locationCode,
    String? bookingStatus,
    String? isOnline,
    String? disciplineId,
    String? trainerId,
  }) {
    return BookingRequest(
      memberId: memberId ?? this.memberId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      locationCode: locationCode ?? this.locationCode,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      isOnline: isOnline ?? this.isOnline,
      disciplineId: disciplineId ?? this.disciplineId,
      trainerId: trainerId ?? this.trainerId,
    );
  }
}
