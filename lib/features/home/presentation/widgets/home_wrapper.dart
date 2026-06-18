import 'dart:math' as math;

import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:portfolio_mobile_app/features/bookings/presentation/pages/bookings_page.dart';
import 'package:portfolio_mobile_app/features/profile/presentation/pages/member_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

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
  static const int _homeTabIndex = 0;

  final Set<int> _visitedIndexes = <int>{};
  bool _loggedFirstInteractiveFrame = false;

  // Each tab page reports what its header should show instead of rendering its
  // own, so the single hoisted PageHeader below can crossfade its title/subtitle
  // between them (its gradient bar stays static). Home's config is seeded
  // eagerly since it's the brand mark and always the first tab seen.
  final Map<int, PageHeaderConfig> _headerConfigs = {
    _homeTabIndex: const PageHeaderConfig(child: BrandHeader(variant: 'small')),
  };

  void _setHeaderConfig(int index, PageHeaderConfig config) {
    if (!mounted) {
      return;
    }
    setState(() {
      _headerConfigs[index] = config;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.put(AppRouter(), permanent: true);
    final authService = Get.find<AuthService>();

    return Obx(() {
      if (!authService.isLoggedIn) {
        return const SizedBox.shrink();
      }

      final navItems = [
        {'icon': LucideIcons.home, 'label': 'Home', 'index': 0},
        {'icon': LucideIcons.calendar, 'label': 'Bookings', 'index': 1},
        {'icon': LucideIcons.libraryBig, 'label': 'Directory', 'index': 6},
        {'icon': LucideIcons.user, 'label': 'Profile', 'index': 5},
      ];

      final pagesByIndex = <int, Widget>{
        0: HomePage(onHeaderChanged: (config) => _setHeaderConfig(0, config)),
        1: BookingsPage(
          onHeaderChanged: (config) => _setHeaderConfig(1, config),
        ),
        6: FitnessDirectoryPage(
          onHeaderChanged: (config) => _setHeaderConfig(6, config),
        ),
        5: ProfilePage(
          onHeaderChanged: (config) => _setHeaderConfig(5, config),
        ),
      };

      final navIndexes = navItems
          .map<int?>((item) => item['index'] as int?)
          .whereType<int>()
          .toList();

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

      final activeHeaderConfig =
          _headerConfigs[safeIndex] ?? const PageHeaderConfig(title: '');

      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A single persistent PageHeader: its gradient bar stays put while
            // its title/subtitle content crossfades on every tab switch.
            PageHeader(
              title: activeHeaderConfig.title,
              subtitle: activeHeaderConfig.subtitle,
              subtitleIcon: activeHeaderConfig.subtitleIcon,
              secondarySubtitle: activeHeaderConfig.secondarySubtitle,
              secondarySubtitleIcon: activeHeaderConfig.secondarySubtitleIcon,
              onBackButtonPressed: activeHeaderConfig.onBackButtonPressed,
              child: activeHeaderConfig.child,
            ),
            Expanded(child: Stack(children: visitedChildren)),
          ],
        ),
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: displayIndex,
          onTap: navCtrl.changeTab,
          items: navItems,
        ),
      );
    });
  }
}
