import 'dart:ui';

enum TrainerFilterField { discipline, location }

enum TrainersSearchMode { discipline, membership }

enum TrainersViewStage { filters, results, availability }

enum CapabilitiesViewStage {
  groupSelection,
  subgroupSelection,
  subgroupItemsSelection,
  capabilityAvailability,
}

class DirectoryOption {
  const DirectoryOption({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;
}

enum FitnessDirectoryView {
  options,
  disciplines,
  disciplineAvailability,
  memberships,
  trainers,
  capabilities,
}
