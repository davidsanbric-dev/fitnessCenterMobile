enum DisciplineSearchMode { discipline, trainer }

enum SchedulingMode { byService, byDisciplineTrainer }

enum MemberFilterKind { rut, name }

class BookingsMemberOption {
  const BookingsMemberOption({
    required this.key,
    required this.label,
    required this.kind,
  });

  final String key;
  final String label;
  final MemberFilterKind kind;
}

class MemberAvailabilityParams {
  const MemberAvailabilityParams({
    required this.serviceLabel,
    required this.primarySelectionLabel,
    required this.searchMode,
    this.trainerId,
    this.trainerDisciplineId,
    this.trainerDisciplineLabel,
  });

  final String serviceLabel;
  final String primarySelectionLabel;
  final DisciplineSearchMode searchMode;
  final String? trainerId;
  final int? trainerDisciplineId;
  final String? trainerDisciplineLabel;
}

class MemberAvailabilityFilters {
  const MemberAvailabilityFilters({
    required this.serviceLabel,
    required this.disciplineId,
    this.disciplineLabel,
    this.trainerId,
    this.trainerLabel,
    required this.searchMode,
  });

  final String serviceLabel;
  final int disciplineId;
  final String? disciplineLabel;
  final String? trainerId;
  final String? trainerLabel;
  final DisciplineSearchMode searchMode;

  String get primaryLabel => searchMode == DisciplineSearchMode.discipline
      ? (disciplineLabel ?? '')
      : (trainerLabel ?? '');
}

String buildMemberFilterKey(MemberFilterKind kind, String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) {
    return '';
  }
  return '${kind.name}::$normalized';
}
