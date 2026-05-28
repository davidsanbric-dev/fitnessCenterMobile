import 'package:portfolio_mobile_app/app/config/app_routes.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:portfolio_mobile_app/features/profile/presentation/pages/personal_member_data_page.dart';
import 'package:portfolio_mobile_app/features/profile/presentation/pages/mfa_enrollment_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showPersonalData = false;
  bool _showMfaSetup = false;

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

  void _openMfaSetup() {
    setState(() {
      _showMfaSetup = true;
    });
  }

  void _closeMfaSetup() {
    setState(() {
      _showMfaSetup = false;
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

    if (_showMfaSetup) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _closeMfaSetup();
        },
        child: Scaffold(body: MfaEnrollmentView(onBack: _closeMfaSetup)),
      );
    }

    final options = [
      _ProfileOption(title: 'Personal Information', onTap: _openPersonalData),
      _ProfileOption(
        title: 'Security and SMS verification',
        onTap: _openMfaSetup,
      ),
      _ProfileOption(
        title: 'Training History',
        onTap: () => _showComingSoon(context),
      ),
      _ProfileOption(
        title: 'Assessment Results',
        onTap: () => _showComingSoon(context),
      ),
      _ProfileOption(
        title: 'Gym Locations',
        onTap: () => _showComingSoon(context),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'My Profile',
              onLogout: () => _handleLogout(context),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
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
  const _ProfileOption({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;
}
