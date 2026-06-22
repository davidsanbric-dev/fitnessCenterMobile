import 'package:fitnesscenter_mobile/app/core/di/locator.dart';
import 'package:fitnesscenter_mobile/features/profile/feature.dart';

class ProfileInjector {
  /// Returns the shared Assessment Results view-model, registering it on first
  /// use. Idempotent so the sub-view (via [SharedViewModelHost]) binds to a
  /// single instance for its lifetime.
  static AssessmentResultsViewModel getAssessmentResultsViewModel() => getOrPut(
    () =>
        AssessmentResultsViewModel(repository: MemberBookingsRepositoryImpl()),
  );

  /// Returns the shared Training History view-model, registering it on first
  /// use. Idempotent so the sub-view (via [SharedViewModelHost]) binds to a
  /// single instance for its lifetime.
  static TrainingHistoryViewModel getTrainingHistoryViewModel() => getOrPut(
    () => TrainingHistoryViewModel(repository: MemberBookingsRepositoryImpl()),
  );

  /// Returns the shared Personal Information view-model, registering it on first
  /// use. Idempotent so the sub-view (via [SharedViewModelHost]) binds to a
  /// single instance for its lifetime.
  static ProfileViewModel getProfileViewModel() =>
      getOrPut(() => ProfileViewModel(repository: ProfileRepositoryImpl()));
}
