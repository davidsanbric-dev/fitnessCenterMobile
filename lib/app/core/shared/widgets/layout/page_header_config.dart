import 'package:flutter/material.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header.dart';

/// Describes what a [PageHeader] should currently display. Pages hosted by
/// the bottom-nav shell report their config up instead of rendering their own
/// [PageHeader], so the shell can own a single header instance and crossfade
/// it between tabs (e.g. the home brand mark fading into a page title).
class PageHeaderConfig {
  const PageHeaderConfig({
    this.title,
    this.child,
    this.subtitle,
    this.subtitleIcon,
    this.secondarySubtitle,
    this.secondarySubtitleIcon,
    this.onBackButtonPressed,
  }) : assert(title != null || child != null);

  final String? title;
  final Widget? child;
  final String? subtitle;
  final IconData? subtitleIcon;
  final String? secondarySubtitle;
  final IconData? secondarySubtitleIcon;
  final VoidCallback? onBackButtonPressed;
}

typedef PageHeaderReporter = void Function(PageHeaderConfig config);

/// Renders [config] as a [PageHeader], or — when [reporter] is supplied —
/// reports it upward and renders nothing instead. Lets a page keep its
/// existing reactive header-computation logic unchanged while letting a host
/// (e.g. the bottom-nav shell) take over actually displaying the header.
class PageHeaderSlot extends StatelessWidget {
  const PageHeaderSlot({super.key, required this.config, this.reporter});

  final PageHeaderConfig config;
  final PageHeaderReporter? reporter;

  @override
  Widget build(BuildContext context) {
    final report = reporter;
    if (report != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => report(config));
      return const SizedBox.shrink();
    }
    return PageHeader(
      title: config.title,
      subtitle: config.subtitle,
      subtitleIcon: config.subtitleIcon,
      secondarySubtitle: config.secondarySubtitle,
      secondarySubtitleIcon: config.secondarySubtitleIcon,
      onBackButtonPressed: config.onBackButtonPressed,
      child: config.child,
    );
  }
}
