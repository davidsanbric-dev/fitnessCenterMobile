import 'dart:math' as math;

import 'package:portfolio_mobile_app/app/core/constants/app_assets.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/diagnostics/runtime_diagnostics.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/pages/available_slots_page.dart';
import 'package:portfolio_mobile_app/features/bookings/presentation/pages/bookings_page.dart';
import 'package:portfolio_mobile_app/features/profile/presentation/pages/member_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:portfolio_mobile_app/app/config/app_router.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/main_bottom_navbar.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/pages/fitness_directory_page.dart';
import 'package:portfolio_mobile_app/features/home/presentation/pages/home_page.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  final Set<int> _visitedIndexes = <int>{};
  bool _loggedFirstBuild = false;
  bool _loggedFirstInteractiveFrame = false;

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.put(AppRouter(), permanent: true);
    final authService = Get.find<AuthService>();

    return Obx(() {
      if (!_loggedFirstBuild) {
        _loggedFirstBuild = true;
        RuntimeDiagnostics.breadcrumb('home-wrapper-first-build');
      }
      if (!authService.isLoggedIn) {
        RuntimeDiagnostics.breadcrumb('home-wrapper-not-logged');
        return const SizedBox.shrink();
      }

      final menuItems = [
        {'icon': AppAssets.profileIcon, 'label': 'Profile', 'index': 5},
        {'icon': Icons.fitness_center, 'label': 'Directory', 'index': 6},
      ];

      final navItems = [
        {'icon': Icons.home_outlined, 'label': 'Home', 'index': 0},
        {'icon': AppAssets.bookingIcon, 'label': 'Book', 'index': 4},
        {'icon': Icons.event_note_outlined, 'label': 'Bookings', 'index': 1},
        {'label': 'More', 'menuItems': menuItems},
      ];

      final pagesByIndex = <int, Widget>{
        0: const HomePage(),
        1: const BookingsPage(),
        4: const AvailableSlotsPage(),
        6: const FitnessDirectoryPage(),
        5: const ProfilePage(),
      };

      final navIndexes = [
        ...navItems.map<int?>((item) => item['index'] as int?).whereType<int>(),
        ...menuItems.map<int>((item) => item['index'] as int),
      ];

      final maxIndex = navIndexes.fold<int>(0, math.max);

      final defaultIndex = navIndexes.contains(0)
          ? 0
          : (navIndexes.isNotEmpty ? navIndexes.first : 0);

      final currentIndex = navCtrl.currentIndex.value;
      final hasAccessToTab = navIndexes.contains(currentIndex);
      final displayIndex = hasAccessToTab ? currentIndex : defaultIndex;
      final safeIndex = displayIndex.clamp(0, maxIndex).toInt();
      // If the previously selected tab is no longer available (e.g. role change),
      // ensure we fall back to a valid tab.

      if (_visitedIndexes.add(safeIndex)) {
        RuntimeDiagnostics.breadcrumb(
          'home-wrapper-visit-tab',
          data: 'tab=$safeIndex visited=${_visitedIndexes.length}',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }

      if (!_loggedFirstInteractiveFrame) {
        _loggedFirstInteractiveFrame = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          RuntimeDiagnostics.breadcrumb(
            'home-wrapper-first-interactive-frame',
            data: 'tab=$safeIndex',
          );
        });
      }

      final visitedChildren = _visitedIndexes
          .map(
            (index) => Offstage(
              offstage: index != safeIndex,
              child: pagesByIndex[index] ?? const SizedBox.shrink(),
            ),
          )
          .toList();

      return Scaffold(
        body: Stack(children: visitedChildren),
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: displayIndex,
          onTap: navCtrl.changeTab,
          items: navItems,
        ),
      );
    });
  }
}
