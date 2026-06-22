import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/utils/format/input.dart';
import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/shared_view_model_host.dart';
import 'package:fitnesscenter_mobile/features/profile/feature.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class PersonalDataPage extends StatelessWidget {
  const PersonalDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: PersonalDataView());
  }
}

class PersonalDataView extends StatefulWidget {
  const PersonalDataView({super.key, this.onBack, this.onHeaderChanged});

  final VoidCallback? onBack;

  /// When provided, reports the header up instead of rendering it directly,
  /// letting a host (the bottom-nav shell) own a single header that
  /// crossfades between tabs.
  final PageHeaderReporter? onHeaderChanged;

  @override
  State<PersonalDataView> createState() => _PersonalDataViewState();
}

class _PersonalDataViewState extends State<PersonalDataView>
    with SharedViewModelHost<PersonalDataView, ProfileViewModel> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _rutController;
  late final TextEditingController _membershipController;

  @override
  ProfileViewModel createViewModel() => ProfileInjector.getProfileViewModel();

  @override
  void initState() {
    super.initState();
    acquireViewModel();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _rutController = TextEditingController();
    _membershipController = TextEditingController();
    // Prefill from whatever the model already holds, then keep the read-only
    // fields in sync as the cached/refreshed claims resolve. The model used to
    // load on GetX-style startup; the ChangeNotifier model has no such hook, so
    // kick off the initial load once mounted.
    _applyPrefill();
    viewModel.addListener(_handleViewModelChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      viewModel.start();
    });
  }

  @override
  void dispose() {
    viewModel.removeListener(_handleViewModelChanged);
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _rutController.dispose();
    _membershipController.dispose();
    releaseViewModel();
    super.dispose();
  }

  void _handleViewModelChanged() {
    if (!mounted) {
      return;
    }
    _applyPrefill();
  }

  void _applyPrefill() {
    _assignIfEmpty(_fullNameController, viewModel.fullName);
    _assignIfEmpty(_emailController, viewModel.email);
    _assignIfEmpty(_phoneController, viewModel.phone);
    _assignIfEmpty(_rutController, _formatRutValue(viewModel.rut));
    _assignIfEmpty(_membershipController, viewModel.selectedMembership);
  }

  void _assignIfEmpty(TextEditingController controller, String? value) {
    if (value == null || value.trim().isEmpty) {
      return;
    }
    if (controller.text.trim().isNotEmpty) {
      return;
    }
    controller.text = value.trim();
  }

  String? _formatRutValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final sanitizedRut = sanitizeRutInput(value);
    if (sanitizedRut.isEmpty) {
      return null;
    }

    return formatRut(sanitizedRut);
  }

  PageHeaderConfig _resolveHeaderConfig() {
    if (widget.onBack == null) {
      return const PageHeaderConfig(title: 'Personal Information');
    }

    // Mirror the Directory page breadcrumb pattern: keep the master section
    // title and surface the current sub-view as an iconed subtitle hint.
    return PageHeaderConfig(
      title: 'My Profile',
      subtitle: 'Personal Information',
      subtitleIcon: LucideIcons.idCard,
      onBackButtonPressed: widget.onBack,
    );
  }

  Widget _buildHeader() {
    return PageHeaderSlot(
      config: _resolveHeaderConfig(),
      reporter: widget.onHeaderChanged,
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      keyboardType: keyboardType,
      decoration: AppTheme.underlineDecoration(label: label),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 25),
        _buildReadOnlyField(
          controller: _fullNameController,
          label: 'Full Name',
        ),
        const SizedBox(height: 18),
        _buildReadOnlyField(
          controller: _phoneController,
          label: 'Phone',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 18),
        _buildReadOnlyField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        _buildReadOnlyField(controller: _rutController, label: 'RUT'),
        const SizedBox(height: 18),
        _buildReadOnlyField(
          controller: _membershipController,
          label: 'Membership Plan',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.of(context).size.width > 480
        ? 40.0
        : 28.0;

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
              child: _buildFormFields(),
            ),
          ),
        ],
      ),
    );
  }
}
