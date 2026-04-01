import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class LocationDto {
  const LocationDto({required this.locationId, this.locationName});

  final int locationId;
  final String? locationName;

  factory LocationDto.fromJson(Map<String, dynamic> json) {
    return LocationDto(
      locationId: normReqInt(json['locationId']),
      locationName: normOptString(json['locationName']),
    );
  }
}
