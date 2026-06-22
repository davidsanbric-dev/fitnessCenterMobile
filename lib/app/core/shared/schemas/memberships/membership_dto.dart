import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';

class MembershipDto {
  const MembershipDto({
    required this.membershipId,
    required this.membershipName,
    this.price,
    this.durationDays,
    this.maxBookingsPerMonth,
  });

  final String membershipId;
  final String membershipName;

  /// Plan price in the company's currency. Null when the catalogue endpoint
  /// does not expose pricing (e.g. the trainer-by-plan listing).
  final double? price;

  /// Length of a billing cycle in days (typically 30).
  final int? durationDays;

  /// Maximum number of sessions a member may book per month under this plan.
  final int? maxBookingsPerMonth;

  factory MembershipDto.fromJson(Map<String, dynamic> json) {
    return MembershipDto(
      membershipId: normReqString(json['membership_plan_id']),
      membershipName: normReqString(json['name']),
      price: _parseDouble(json['price']),
      durationDays: normOptInt(json['duration_days']),
      maxBookingsPerMonth: normOptInt(json['max_bookings_per_month']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }
}
