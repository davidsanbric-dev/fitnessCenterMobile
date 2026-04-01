import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class AvailableSlotsRequest {
  static const String _onlineFlag = 'true';

  const AvailableSlotsRequest({
    required this.disciplineId,
    this.trainerId,
    required this.locationId,
    this.isOnline = false,
  });

  final int disciplineId;
  final String? trainerId;
  final int locationId;
  final bool isOnline;

  // Update later to remove hardcoded date range values
  //(Including UI date-range picker)
  Map<String, String> toQueryParameters({
    int bookingDuration = 0,
    int windowDays = 14,
  }) {
    final startDateTime = DateTime.now().toLocal();
    final endDateTime = startDateTime.add(Duration(days: windowDays));
    final normalizedTrainer = normalizeValue(trainerId);
    final query = <String, String>{
      'startDateTime': formatDateIso(startDateTime),
      'endDateTime': formatDateIso(endDateTime),
      'bookingDuration': bookingDuration.toString(),
      if (disciplineId > 0) 'disciplineCode': disciplineId.toString(),
      if (locationId > 0) 'locationCode': locationId.toString(),
      'isOnline': isOnline ? _onlineFlag : 'false',
      if (normalizedTrainer != null) 'trainerCode': normalizedTrainer,
    };

    return query;
  }

  Map<String, dynamic> toJson() => {
    'disciplineId': disciplineId,
    'locationId': locationId,
    'isOnline': isOnline,
    if (trainerId?.isNotEmpty ?? false) 'trainerId': trainerId,
  };

  AvailableSlotsRequest copyWith({
    int? disciplineId,
    String? trainerId,
    int? locationId,
    bool? isOnline,
  }) {
    return AvailableSlotsRequest(
      disciplineId: disciplineId ?? this.disciplineId,
      trainerId: trainerId ?? this.trainerId,
      locationId: locationId ?? this.locationId,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
