import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class AvailableSlotsRequest {
  const AvailableSlotsRequest({
    required this.disciplineId,
    this.trainerId,
    required this.locationId,
  });

  final int disciplineId;
  final String? trainerId;
  final int locationId;

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
      if (normalizedTrainer != null) 'trainerCode': normalizedTrainer,
    };

    return query;
  }

  Map<String, dynamic> toJson() => {
    'disciplineId': disciplineId,
    'locationId': locationId,
    if (trainerId?.isNotEmpty ?? false) 'trainerId': trainerId,
  };

  AvailableSlotsRequest copyWith({
    int? disciplineId,
    String? trainerId,
    int? locationId,
  }) {
    return AvailableSlotsRequest(
      disciplineId: disciplineId ?? this.disciplineId,
      trainerId: trainerId ?? this.trainerId,
      locationId: locationId ?? this.locationId,
    );
  }
}
