import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/pages/available_slots_page.dart';
import 'package:fitnesscenter_mobile/features/bookings/presentation/pages/bookings_page.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/presentation/pages/fitness_directory_page.dart';
import 'package:fitnesscenter_mobile/features/home/presentation/pages/home_page.dart';
import 'package:fitnesscenter_mobile/features/profile/presentation/pages/member_profile_page.dart';

/// Single source of truth for the app's tabs / logical navigation destinations.
///
/// Each [AppTab] owns its stable [id], its bottom-nav presentation, and how to
/// build its page. Features react to the active tab type-safely via
/// `ever<AppTab>(appRouter.current, ...)`; the [id] survives only as the
/// integer the generic `MainBottomNavBar` speaks at its boundary. Adding,
/// reordering or hiding a tab is a one-line change here instead of edits
/// scattered across the shell, the home page and every feature that reacts to
/// tab changes.
///
/// The [id] values are intentionally sparse (2 and 3 are unused historical
/// gaps). Display order is owned separately by [kNavTabs], so it can differ
/// from both declaration order and [id] order.
enum AppTab {
  home(id: 0, icon: LucideIcons.home, label: 'Home'),
  bookings(id: 1, icon: LucideIcons.calendar, label: 'Bookings'),

  /// Reached as a standalone route rather than a bottom-nav tab, so it is
  /// absent from [kNavTabs]. It still owns a logical [id] because its book-flow
  /// reset listener keys on tab changes.
  availableSlots(id: 4, icon: LucideIcons.calendar, label: 'Slots'),
  profile(id: 5, icon: LucideIcons.user, label: 'Profile'),
  fitnessDirectory(id: 6, icon: LucideIcons.libraryBig, label: 'Directory');

  const AppTab({required this.id, required this.icon, required this.label});

  final int id;
  final IconData icon;
  final String label;

  /// Resolves the [AppTab] for a logical [id], falling back to [home] for any
  /// unknown/stale value (e.g. a tab that disappeared after a role change).
  static AppTab fromId(int id) =>
      values.firstWhere((tab) => tab.id == id, orElse: () => home);

  /// Builds this tab's page, wiring its header reporter to the host shell so the
  /// shell can own a single crossfading [PageHeader] across tabs.
  Widget buildPage({PageHeaderReporter? onHeaderChanged}) {
    switch (this) {
      case AppTab.home:
        return HomePage(onHeaderChanged: onHeaderChanged);
      case AppTab.bookings:
        return BookingsPage(onHeaderChanged: onHeaderChanged);
      case AppTab.fitnessDirectory:
        return FitnessDirectoryPage(onHeaderChanged: onHeaderChanged);
      case AppTab.profile:
        return ProfilePage(onHeaderChanged: onHeaderChanged);
      case AppTab.availableSlots:
        return const AvailableSlotsPage();
    }
  }
}

/// The tabs shown in the bottom navigation bar, in display order. This list —
/// not [AppTab] declaration order — defines what the shell renders and in what
/// sequence.
const List<AppTab> kNavTabs = [
  AppTab.home,
  AppTab.bookings,
  AppTab.fitnessDirectory,
  AppTab.profile,
];
