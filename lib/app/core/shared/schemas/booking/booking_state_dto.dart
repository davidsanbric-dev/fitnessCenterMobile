import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';

class BookingStateDto {
  const BookingStateDto({required this.code, required this.label});

  final String code;
  final String label;

  factory BookingStateDto.fromJson(Map<String, dynamic> json) {
    return BookingStateDto(
      code: normReqString(json['code']),
      label: normReqString(json['label']),
    );
  }
}
