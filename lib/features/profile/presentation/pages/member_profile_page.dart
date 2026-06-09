import 'package:portfolio_mobile_app/app/config/app_routes.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:portfolio_mobile_app/features/profile/presentation/pages/personal_member_data_page.dart';
import 'package:portfolio_mobile_app/app/core/services/profile_navigation_service.dart';
import 'package:portfolio_mobile_app/features/profile/presentation/pages/assessment_results_page.dart';
import 'package:portfolio_mobile_app/features/profile/presentation/pages/training_history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showPersonalData = false;
  bool _showTrainingHistory = false;
  bool _showAssessmentResults = false;
  Worker? _navWorker;

  @override
  void initState() {
    super.initState();
    // The profile tab is lazily mounted (Offstage + _visitedIndexes in
    // HomeWrapper), so it may not exist yet when another page calls
    // requestTrainingHistory(). Two paths:
    //   1. Page already mounted when request fires → ever() catches the change.
    //   2. Page mounts AFTER request was set → ever() sees no change (value was
    //      already 'training_history' at registration time); addPostFrameCallback
    //      handles this by checking the current value on the first frame.
    final navService = ProfileNavigationService.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumePending());
    _navWorker = ever<String?>(navService.pendingSubView, (_) => _consumePending());
  }

  void _consumePending() {
    final navService = ProfileNavigationService.instance;
    final view = navService.pendingSubView.value;
    if (view == null || !mounted) return;
    navService.consume();
    if (view == 'training_history') {
      setState(() {
        _showPersonalData = false;
        _showAssessmentResults = false;
        _showTrainingHistory = true;
      });
    }
  }

  @override
  void dispose() {
    _navWorker?.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final authService = Get.find<AuthService>();
    try {
      await authService.logout();
      await Get.offAllNamed(AppRoutes.login);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not sign out: $error')),
      );
    }
  }

  void _openPersonalData() {
    setState(() {
      _showPersonalData = true;
    });
  }

  void _closePersonalData() {
    setState(() {
      _showPersonalData = false;
    });
  }

  void _openTrainingHistory() {
    setState(() {
      _showTrainingHistory = true;
    });
  }

  void _closeTrainingHistory() {
    setState(() {
      _showTrainingHistory = false;
    });
  }

  void _openAssessmentResults() {
    setState(() {
      _showAssessmentResults = true;
    });
  }

  void _closeAssessmentResults() {
    setState(() {
      _showAssessmentResults = false;
    });
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This section will be available soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showPersonalData) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _closePersonalData();
        },
        child: Scaffold(body: PersonalDataView(onBack: _closePersonalData)),
      );
    }

    if (_showTrainingHistory) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _closeTrainingHistory();
        },
        child: Scaffold(
          body: TrainingHistoryView(onBack: _closeTrainingHistory),
        ),
      );
    }

    if (_showAssessmentResults) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _closeAssessmentResults();
        },
        child: Scaffold(
          body: AssessmentResultsView(onBack: _closeAssessmentResults),
        ),
      );
    }

    final options = [
      _ProfileOption(title: 'Personal Information', onTap: _openPersonalData),
      _ProfileOption(
        title: 'Training History',
        onTap: _openTrainingHistory,
      ),
      _ProfileOption(
        title: 'Assessment Results',
        onTap: _openAssessmentResults,
      ),
      _ProfileOption(
        title: 'Gym Locations',
        onTap: () => _showComingSoon(context),
      ),
      _ProfileOption(
        title: 'Sign Out',
        onTap: () => _handleLogout(context),
        isDestructive: true,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeaderScope(
              showLogout: false,
              child: PageHeader(title: 'My Profile'),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 25,
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    title: Text(
                      option.title,
                      style: AppTheme.listTileTitleStyle(
                        context,
                        isDestructive: option.isDestructive,
                      ),
                    ),
                    onTap: option.onTap,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    minVerticalPadding: 10,
                  );
                },
                separatorBuilder: (context, _) => Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade300,
                ),
                itemCount: options.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption {
  const _ProfileOption({
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
}
