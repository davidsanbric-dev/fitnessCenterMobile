import 'dart:async';
import 'dart:convert';

import 'package:portfolio_mobile_app/app/config/app_routes.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/api/members_api.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/member/member_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:portfolio_mobile_app/features/profile/presentation/pages/personal_member_data_page.dart';
import 'package:portfolio_mobile_app/app/core/services/profile_navigation_service.dart';
import 'package:portfolio_mobile_app/features/profile/presentation/pages/assessment_results_page.dart';
import 'package:portfolio_mobile_app/features/profile/presentation/pages/training_history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.onHeaderChanged});

  /// When provided, Profile (and whichever sub-view is currently open) reports
  /// its header up instead of rendering it directly, letting a host (the
  /// bottom-nav shell) own a single header that crossfades between tabs.
  final PageHeaderReporter? onHeaderChanged;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showPersonalData = false;
  bool _showTrainingHistory = false;
  bool _showAssessmentResults = false;
  Worker? _navWorker;

  final MembersApi _membersApi = MembersApi();
  final ImagePicker _imagePicker = ImagePicker();
  MemberDto? _member;
  bool _avatarUpdating = false;

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
    _navWorker = ever<String?>(
      navService.pendingSubView,
      (_) => _consumePending(),
    );
    unawaited(_loadMember());
  }

  Future<void> _loadMember() async {
    try {
      final member = await _membersApi.getCurrentMember();
      if (!mounted) return;
      setState(() => _member = member);
    } catch (_) {
      // The avatar header falls back to a placeholder if the member load fails;
      // the rest of the profile menu stays usable.
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_avatarUpdating) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 90,
      );
      if (picked == null) return;

      setState(() => _avatarUpdating = true);
      final bytes = await picked.readAsBytes();
      final mime = _mimeForPath(picked.path);
      final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
      final updated = await _membersApi.updateAvatar(dataUrl);
      if (!mounted) return;
      setState(() => _member = updated);
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile photo updated.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not update the photo: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _avatarUpdating = false);
      }
    }
  }

  String _mimeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
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
    } else if (view == 'assessment_results') {
      setState(() {
        _showPersonalData = false;
        _showTrainingHistory = false;
        _showAssessmentResults = true;
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

  /// Tappable circular avatar shown above the options menu. Tapping opens the
  /// gallery picker and uploads the chosen image as the member's profile photo.
  Widget _buildAvatarHeader(BuildContext context) {
    final accent = AppTheme.brandAccentColor(context);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final avatarUrl = _member?.absoluteAvatarUrl;
    final name = _member?.fullName.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: _avatarUpdating ? null : _pickAndUploadAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: accent.withValues(alpha: 0.12),
                  foregroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Icon(LucideIcons.user, size: 36, color: accent)
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: scaffoldBg, width: 2),
                  ),
                  child: _avatarUpdating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          LucideIcons.camera,
                          size: 14,
                          color: Colors.white,
                        ),
                ),
              ],
            ),
          ),
          if (name.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
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
        child: Scaffold(
          body: PersonalDataView(
            onBack: _closePersonalData,
            onHeaderChanged: widget.onHeaderChanged,
          ),
        ),
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
          body: TrainingHistoryView(
            onBack: _closeTrainingHistory,
            onHeaderChanged: widget.onHeaderChanged,
          ),
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
          body: AssessmentResultsView(
            onBack: _closeAssessmentResults,
            onHeaderChanged: widget.onHeaderChanged,
          ),
        ),
      );
    }

    final options = [
      _ProfileOption(
        title: 'Personal Information',
        icon: LucideIcons.idCard,
        onTap: _openPersonalData,
      ),
      _ProfileOption(
        title: 'Training History',
        icon: LucideIcons.history,
        onTap: _openTrainingHistory,
      ),
      _ProfileOption(
        title: 'Assessment Results',
        icon: LucideIcons.clipboardList,
        onTap: _openAssessmentResults,
      ),
      _ProfileOption(
        title: 'Sign Out',
        icon: LucideIcons.logOut,
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
            PageHeaderScope(
              showLogout: false,
              child: PageHeaderSlot(
                config: const PageHeaderConfig(title: 'My Profile'),
                reporter: widget.onHeaderChanged,
              ),
            ),
            _buildAvatarHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 25,
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final titleStyle = AppTheme.listTileTitleStyle(
                    context,
                    isDestructive: option.isDestructive,
                  );
                  return ListTile(
                    leading: Icon(
                      option.icon,
                      size: 22,
                      color: option.isDestructive
                          ? titleStyle.color
                          : AppTheme.brandAccentColor(context),
                    ),
                    title: Text(option.title, style: titleStyle),
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
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
}
