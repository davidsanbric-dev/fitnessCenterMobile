import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainer_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainers_by_membership_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainers_request.dart';

class TrainersApi extends ApiBase {
  Future<List<TrainerDto>> getTrainers(TrainersRequest request) async {
    final query = request.toQueryParameters();
    return getDataListAsync<TrainerDto>(
      url: ApiUrls.trainersUrl,
      requestErrorMessage: 'Error fetching trainers',
      queryParameters: <String, String>{
        if ((query['disciplineCode'] ?? '').trim().isNotEmpty)
          'discipline_id': query['disciplineCode']!,
        if ((query['locationCode'] ?? '').trim().isNotEmpty)
          'location_code': _toLocationCode(query['locationCode']!),
      },
      fromJson: TrainerDto.fromJson,
    );
  }

  Future<List<TrainerDto>> getTrainersByMembership(
    TrainersByMembershipRequest request,
  ) async {
    final query = request.toQueryParameters();
    return getDataListAsync<TrainerDto>(
      url: ApiUrls.trainersUrl,
      requestErrorMessage: 'Error fetching trainers by membership plan',
      queryParameters: <String, String>{
        'membership_plan_id': query['membershipId'] ?? '',
        'discipline_id': query['disciplineCode'] ?? '',
        'location_code': _toLocationCode(query['locationCode'] ?? ''),
      },
      fromJson: TrainerDto.fromJson,
    );
  }

  String _toLocationCode(String locationCode) {
    switch (locationCode.trim()) {
      case '1':
        return 'LOC001';
      case '2':
        return 'LOC002';
      default:
        return locationCode.trim();
    }
  }
}
