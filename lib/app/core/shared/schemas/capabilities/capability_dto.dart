import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class CapabilityDto {
  const CapabilityDto({
    required this.id,
    required this.description,
    this.scheduleType = '',
    this.preparation = '',
    this.pdfCode = '',
  });

  final int id;
  final String description;
  final String scheduleType;
  final String preparation;
  final String pdfCode;

  // Unions the three class-hierarchy summary contracts from GET /class-categories,
  // .../subcategories and .../class-types (all snake_case): the id comes from
  // whichever node this is — a category, a subcategory or a class type. Only the
  // class-type summary carries schedule_type/preparation_info/pdf_code.
  factory CapabilityDto.fromJson(Map<String, dynamic> json) {
    final id =
        normOptInt(json['category_id']) ??
        normOptInt(json['subcategory_id']) ??
        normOptInt(json['class_type_id']) ??
        0;
    return CapabilityDto(
      id: id,
      description: normOptString(json['name']) ?? '',
      scheduleType: normOptString(json['schedule_type']) ?? '',
      preparation: normOptString(json['preparation_info']) ?? '',
      pdfCode: normOptString(json['pdf_code']) ?? '',
    );
  }
}
