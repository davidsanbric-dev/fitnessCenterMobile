import 'package:fitnesscenter_mobile/app/core/api/shared/api_base.dart';
import 'package:fitnesscenter_mobile/app/core/constants/api_urls.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/trainer/trainer_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/trainer/trainers_by_membership_request.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/trainer/trainers_request.dart';

class TrainersApi extends ApiBase {
  Future<List<TrainerDto>> getTrainers(TrainersRequest request) async {
    final query = request.toQueryParameters();
    return getDataListAsync<TrainerDto>(
      url: ApiUrls.trainersUrl,
      requestErrorMessage: 'Error fetching trainers',
      queryParameters: <String, String>{
        if ((query['disciplineCode'] ?? '').trim().isNotEmpty)
          'discipline_id': query['disciplineCode']!,
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
      },
      fromJson: TrainerDto.fromJson,
    );
  }
}
