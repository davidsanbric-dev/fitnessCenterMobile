import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class CapabilityDto {
  const CapabilityDto({
    required this.id,
    required this.description,
    required this.locationId,
    this.scheduleType = '',
    this.preparation = '',
    this.pdfCode = '',
  });

  final int id;
  final String description;
  final int locationId;
  final String scheduleType;
  final String preparation;
  final String pdfCode;

  factory CapabilityDto.fromJson(Map<String, dynamic> json) {
    final id =
        normOptInt(json['id']) ??
        normOptInt(json['categoryId']) ??
        normOptInt(json['category_id']) ??
        normOptInt(json['subcategoryId']) ??
        normOptInt(json['subcategory_id']) ??
        normOptInt(json['classTypeId']) ??
        normOptInt(json['class_type_id']) ??
        0;
    final description =
        normOptString(json['description']) ?? normOptString(json['name']) ?? '';
    final locationId =
        normOptInt(json['locationId']) ?? normOptInt(json['location_id']) ?? 0;
    return CapabilityDto(
      id: id,
      description: description,
      locationId: locationId,
      scheduleType:
          normOptString(json['scheduleType']) ??
          normOptString(json['schedule_type']) ??
          '',
      preparation:
          normOptString(json['preparation']) ??
          normOptString(json['preparation_info']) ??
          '',
      pdfCode:
          normOptString(json['pdfCode']) ??
          normOptString(json['pdf_code']) ??
          '',
    );
  }
}
