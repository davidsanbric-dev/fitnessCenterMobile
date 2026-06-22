import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/state/available_slots_by_discipline_trainer_ui_notifier.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/state/available_slots_by_discipline_trainer_ui_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final availableSlotsFilterUiProvider = StateNotifierProvider.autoDispose
    .family<
      AvailableSlotsFilterUiNotifier,
      AvailableSlotsFilterUiState,
      String
    >((_, __) => AvailableSlotsFilterUiNotifier());
