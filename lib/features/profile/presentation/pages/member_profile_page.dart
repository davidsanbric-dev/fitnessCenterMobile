import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:convert';

import 'package:fitnesscenter_mobile/app/config/app_routes.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/api/members_api.dart';
import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/member/member_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header_scope.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/slide_page_switcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:fitnesscenter_mobile/features/profile/presentation/pages/personal_member_data_page.dart';
import 'package:fitnesscenter_mobile/app/core/services/profile_navigation_service.dart';
import 'package:fitnesscenter_mobile/features/profile/presentation/pages/assessment_results_page.dart';
import 'package:fitnesscenter_mobile/features/profile/presentation/pages/training_history_page.dart';

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
        SnackBar(
          content: Text(AppLocalizations.of(context).profilePhotoUpdated),
        ),
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Each profile view is a self-contained card (its own header + content);
    // the menu is the root (depth 0) and any sub-view sits one level deeper
    // (depth 1), so the slide switcher slides the menu out to the left while a
    // sub-view slides in from the right, and reverses on back.
    final String viewKey;
    final Widget viewChild;
    if (_showPersonalData) {
      viewKey = 'personal';
      viewChild = PersonalDataView(
        onBack: _closePersonalData,
        onHeaderChanged: widget.onHeaderChanged,
      );
    } else if (_showTrainingHistory) {
      viewKey = 'training';
      viewChild = TrainingHistoryView(
        onBack: _closeTrainingHistory,
        onHeaderChanged: widget.onHeaderChanged,
      );
    } else if (_showAssessmentResults) {
      viewKey = 'assessment';
      viewChild = AssessmentResultsView(
        onBack: _closeAssessmentResults,
        onHeaderChanged: widget.onHeaderChanged,
      );
    } else {
      viewKey = 'menu';
      viewChild = _buildMenu(context);
    }

    final isSubView = viewKey != 'menu';
    return PopScope(
      // Only intercept the system back gesture while a sub-view is open, where
      // it should return to the menu instead of leaving the profile tab.
      canPop: !isSubView,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !isSubView) return;
        _closeCurrentSubView();
      },
      child: Scaffold(
        body: SlidePageSwitcher(
          depth: isSubView ? 1 : 0,
          stageKey: viewKey,
          child: viewChild,
        ),
      ),
    );
  }

  void _closeCurrentSubView() {
    if (_showPersonalData) {
      _closePersonalData();
    } else if (_showTrainingHistory) {
      _closeTrainingHistory();
    } else if (_showAssessmentResults) {
      _closeAssessmentResults();
    }
  }

  Widget _buildMenu(BuildContext context) {
    final options = [
      _ProfileOption(
        title: AppLocalizations.of(context).profilePersonalInfo,
        icon: LucideIcons.idCard,
        onTap: _openPersonalData,
      ),
      _ProfileOption(
        title: AppLocalizations.of(context).profileTrainingHistory,
        icon: LucideIcons.history,
        onTap: _openTrainingHistory,
      ),
      _ProfileOption(
        title: AppLocalizations.of(context).profileAssessmentResults,
        icon: LucideIcons.clipboardList,
        onTap: _openAssessmentResults,
      ),
      _ProfileOption(
        title: AppLocalizations.of(context).profileSignOut,
        icon: LucideIcons.logOut,
        onTap: () => _handleLogout(context),
        isDestructive: true,
      ),
    ];

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeaderScope(
            showLogout: false,
            child: PageHeaderSlot(
              config: PageHeaderConfig(
                title: AppLocalizations.of(context).profileTitle,
              ),
              reporter: widget.onHeaderChanged,
            ),
          ),
          _buildAvatarHeader(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
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
              separatorBuilder: (context, _) =>
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              itemCount: options.length,
            ),
          ),
        ],
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
