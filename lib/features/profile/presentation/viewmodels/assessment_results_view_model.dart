import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/profile/domain/domain.dart';

/// Drives the Assessment Results sub-page: completed bookings that carry a
/// trainer feedback note. The full list is held in memory so the view can
/// filter/display without extra fetches.
class AssessmentResultsViewModel extends ViewModelBase {
  AssessmentResultsViewModel({required MemberBookingsRepository repository})
    : _repository = repository;

  final MemberBookingsRepository _repository;

  final List<BookingDto> _completed = <BookingDto>[];
  bool isLoading = false;
  String? error;

  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  /// Only sessions where the trainer left a note.
  List<BookingDto> get assessments => _completed
      .where((b) => (b.notes ?? '').trim().isNotEmpty)
      .toList(growable: false);

  Future<void> load() async {
    if (isLoading) return;

    await runLoad<List<BookingDto>>(
      setLoading: (value) => isLoading = value,
      setError: (message) => error = message,
      loader: () => _repository.fetchCompletedBookings(),
      onSuccess: (items) {
        _completed
          ..clear()
          ..addAll(items);
        _hasLoaded = true;
      },
      onError: () => _completed.clear(),
      unexpectedErrorMessage:
          'Unexpected error while loading assessment results',
    );
  }

  Future<void> reload() => load();
}
