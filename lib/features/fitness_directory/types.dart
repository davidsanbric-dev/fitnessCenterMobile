import 'dart:ui';

import 'package:flutter/widgets.dart' show IconData;

enum TrainerFilterField { discipline }

enum TrainersSearchMode { discipline, membership }

enum TrainersViewStage { filters, results, availability }

enum CapabilitiesViewStage {
  groupSelection,
  subgroupSelection,
  subgroupItemsSelection,
  capabilityAvailability,
}

class DirectoryOption {
  const DirectoryOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
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
