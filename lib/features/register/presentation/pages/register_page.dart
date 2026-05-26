import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/services/register_email_verification_service.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_bloc.dart';
import 'package:portfolio_mobile_app/features/register/presentation/pages/first_step_page.dart';
import 'package:portfolio_mobile_app/features/register/presentation/pages/second_step_page.dart';
import 'package:portfolio_mobile_app/features/register/presentation/pages/fourth_step_page.dart';
import 'package:portfolio_mobile_app/features/register/presentation/pages/third_step_page.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/steps_progress_header.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.emailVerificationOobCode});

  final String? emailVerificationOobCode;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const int _maxSteps = 4;
  static const Duration _switchDuration = Duration(milliseconds: 250);

  final ApplyEmailVerificationActionCodeUseCase
  _applyEmailVerificationActionCodeUseCase =
      Get.find<ApplyEmailVerificationActionCodeUseCase>();
  final RegisterEmailVerificationService _registerEmailVerificationService =
      Get.find<RegisterEmailVerificationService>();

  int _currentStep = 1;
  bool _isProcessingEmailVerificationLink = false;
  StreamSubscription<String>? _emailVerificationSubscription;

  @override
  void initState() {
    super.initState();
    _emailVerificationSubscription = _registerEmailVerificationService
        .codeStream
        .listen(_handleEmailVerificationCode);

    final pendingCode = _registerEmailVerificationService.takePendingCode();
    final incomingCode = widget.emailVerificationOobCode?.trim();
    final initialCode = incomingCode != null && incomingCode.isNotEmpty
        ? incomingCode
        : pendingCode;
    if (initialCode != null && initialCode.isNotEmpty) {
      _handleEmailVerificationCode(initialCode);
    }
  }

  @override
  void dispose() {
    _emailVerificationSubscription?.cancel();
    super.dispose();
  }

  void _goToStep(int step) {
    final int clamped = step.clamp(1, _maxSteps);
    if (clamped == _currentStep) {
      return;
    }
    setState(() => _currentStep = clamped);
  }

  void _handleBack() {
    if (_currentStep > 1) {
      _goToStep(_currentStep - 1);
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _handleEmailVerificationCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty || _isProcessingEmailVerificationLink) {
      return;
    }

    setState(() => _isProcessingEmailVerificationLink = true);
    try {
      await _applyEmailVerificationActionCodeUseCase(code: trimmed);
      if (!mounted) return;
      _goToStep(4);
      Get.snackbar(
        'Email verified',
        'Link validated. Continue with your password.',
      );
    } on ApiException catch (error) {
      Get.snackbar('Could not validate', error.message);
    } catch (error) {
      Get.snackbar('Unexpected error', 'Could not validate the link: $error');
    } finally {
      if (mounted) {
        setState(() => _isProcessingEmailVerificationLink = false);
      }
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return FirstStepPage(
          onContinue: () => _goToStep(2),
          onBack: _handleBack,
        );
      case 2:
        return SecondStepPage(
          onBack: _handleBack,
          onContinue: () => _goToStep(3),
        );
      case 3:
        return ThirdStepPage(onBack: _handleBack);
      case 4:
        return FourthStepPage(
          onBack: _handleBack,
          onContinue: () => Navigator.of(context).maybePop(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step $_currentStep',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.brandBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StepsProgressHeader(currentStep: _currentStep),
                    if (_isProcessingEmailVerificationLink) ...[
                      const SizedBox(height: 14),
                      const LinearProgressIndicator(minHeight: 3),
                    ],
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: _switchDuration,
                      child: SizedBox(
                        key: ValueKey(_currentStep),
                        child: _buildStepContent(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
