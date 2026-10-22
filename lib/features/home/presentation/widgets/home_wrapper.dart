import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/brand/brand_header.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitnesscenter_mobile/app/config/app_router.dart';
import 'package:fitnesscenter_mobile/app/config/app_tab.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/main_bottom_navbar.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  /// Tabs the user has visited, by [AppTab.id]. Each visited tab stays mounted
  /// (offstage) so its state survives tab switches; unvisited tabs are built
  /// lazily on first selection.
  final Set<int> _visitedTabIds = <int>{};

  // Each tab page reports what its header should show instead of rendering its
  // own, so the single hoisted PageHeader below can crossfade its title/subtitle
  // between them (its gradient bar stays static). Home's config is seeded
  // eagerly since it's the brand mark and always the first tab seen.
  final Map<int, PageHeaderConfig> _headerConfigs = {
    AppTab.home.id: const PageHeaderConfig(
      child: BrandHeader(variant: 'small'),
    ),
  };

  void _setHeaderConfig(int tabId, PageHeaderConfig config) {
    if (!mounted) {
      return;
    }
    setState(() {
      _headerConfigs[tabId] = config;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<AppRouter>();
    final authService = Get.find<AuthService>();

    return Obx(() {
      if (!authService.isLoggedIn) {
        return const SizedBox.shrink();
      }

      // Resolve the selected tab to a renderable nav destination, falling back
      // to Home if it is not a bottom-nav tab (e.g. a logical-only destination,
      // or a tab removed after a role change).
      final selectedTab = navCtrl.current.value;
      final activeTab = kNavTabs.contains(selectedTab)
          ? selectedTab
          : AppTab.home;

      // First visit to a tab: build it, then schedule a rebuild so the newly
      // mounted page joins the offstage stack.
      if (_visitedTabIds.add(activeTab.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }

      final visitedChildren = [
        for (final tab in kNavTabs)
          if (_visitedTabIds.contains(tab.id))
            Offstage(
              offstage: tab.id != activeTab.id,
              child: tab.buildPage(
                onHeaderChanged: (config) => _setHeaderConfig(tab.id, config),
              ),
            ),
      ];

      final activeHeaderConfig =
          _headerConfigs[activeTab.id] ?? const PageHeaderConfig(title: '');

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
          currentIndex: activeTab.id,
          onTap: navCtrl.changeTab,
          items: [
            for (final tab in kNavTabs)
              NavBarItem(
                icon: tab.icon,
                label: tab.labelFor(context),
                index: tab.id,
              ),
          ],
        ),
      );
    });
  }
}
