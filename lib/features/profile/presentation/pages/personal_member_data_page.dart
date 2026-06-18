import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/input.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header_config.dart';
import 'package:portfolio_mobile_app/features/profile/bloc/profile_bloc.dart';
import 'package:portfolio_mobile_app/features/profile/bloc/profile_event.dart';
import 'package:portfolio_mobile_app/features/profile/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _PersonalDataViewState extends State<PersonalDataView> {
  late final ProfileBloc _profileBloc;
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _rutController;
  late final TextEditingController _membershipController;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _rutController = TextEditingController();
    _membershipController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _profileBloc.add(const ProfileStarted());
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _rutController.dispose();
    _membershipController.dispose();
    _profileBloc.close();
    super.dispose();
  }

  void _applyPrefill(ProfileState state) {
    _assignIfEmpty(_fullNameController, state.fullName);
    _assignIfEmpty(_emailController, state.email);
    _assignIfEmpty(_phoneController, state.phone);
    _assignIfEmpty(_rutController, _formatRutValue(state.rut));
    _assignIfEmpty(_membershipController, state.selectedMembership);
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

    return BlocProvider.value(
      value: _profileBloc,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listenWhen: (previous, current) =>
                    previous.fullName != current.fullName ||
                    previous.email != current.email ||
                    previous.phone != current.phone ||
                    previous.rut != current.rut ||
                    previous.selectedMembership != current.selectedMembership,
                listener: (context, state) => _applyPrefill(state),
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      24,
                    ),
                    child: _buildFormFields(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
