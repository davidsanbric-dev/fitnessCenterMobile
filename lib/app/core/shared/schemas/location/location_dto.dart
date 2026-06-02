import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class LocationDto {
  const LocationDto({
    required this.locationId,
    this.locationName,
    this.locationCode,
  });

  final int locationId;
  final String? locationName;

  /// Real `/statics` location code (e.g. `LOC001`) for the logged-in company.
  final String? locationCode;

  factory LocationDto.fromJson(Map<String, dynamic> json) {
    return LocationDto(
      locationId: normReqInt(json['locationId']),
      locationName: normOptString(json['locationName']),
      locationCode: normOptString(json['locationCode']),
    );
  }
}
