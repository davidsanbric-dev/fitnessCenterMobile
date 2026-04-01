import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/core/api/user_api.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_bloc.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_state.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/user/create_user_request.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/fourth_step_form.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/registration_message.dart';

class FourthStepPage extends StatefulWidget {
  const FourthStepPage({super.key, this.onContinue, this.onBack});

  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  State<FourthStepPage> createState() => _FourthStepPageState();
}

class _FourthStepPageState extends State<FourthStepPage> {
  final EnsureRegisterUserCredentialsUseCase
  _ensureRegisterUserCredentialsUseCase =
      Get.find<EnsureRegisterUserCredentialsUseCase>();
  final UserApi _userApi = UserApi();

  bool _showResult = false;
  bool _isSavingPassword = false;
  String? _resultErrorMessage;

  Future<void> _handleContinue() async {
    if (_isSavingPassword) {
      return;
    }
    final registerState = context.read<RegisterBloc>().state;
    final newPassword = registerState.password;
    final email = registerState.email.trim();
    if (!registerState.hasSignedDocumentId) {
      setState(() {
        _showResult = true;
        _resultErrorMessage =
            'Signed terms document not found. Repeat the signature to continue.';
      });
      return;
    }
    setState(() => _isSavingPassword = true);
    try {
      await _ensureRegisterUserCredentialsUseCase(
        email: email,
        password: newPassword,
      );
      final request = _buildCreateUserRequest(
        registerState,
        password: newPassword,
      );
      try {
        await _userApi.createUser(request: request);
      } on ApiException catch (error) {
        if (!_isAlreadyCreatedError(error.message)) {
          rethrow;
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _showResult = true;
        _resultErrorMessage = null;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.message.trim();
      setState(() {
        _showResult = true;
        _resultErrorMessage = message.isEmpty
            ? 'Could not complete registration. Please try again.'
            : message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _showResult = true;
        _resultErrorMessage = 'Could not complete registration. Detail: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isSavingPassword = false);
      }
    }
  }

  void _handleRetry() {
    if (_isSavingPassword) {
      return;
    }
    setState(() {
      _showResult = false;
      _resultErrorMessage = null;
    });
  }

  CreateUserRequest _buildCreateUserRequest(
    RegisterState state, {
    required String password,
  }) {
    final day = state.birthDay.trim().padLeft(2, '0');
    final month = state.birthMonth.trim().padLeft(2, '0');
    final year = state.birthYear.trim();
    final dateOfBirth = [year, month, day].join('-');
    final email = state.email.trim();
    final memberId = state.rut.trim().isNotEmpty ? state.rut : state.memberId;

    return CreateUserRequest.forMemberRegistration(
      mail: email,
      dateOfBirth: dateOfBirth,
      identificationType: state.identificationType,
      memberId: memberId,
      firstName: state.firstName,
      paternalLastName: state.paternalSurname,
      maternalLastName: state.maternalSurname,
      landlinePhone: state.landlinePhone,
      mobilePhone: state.cellPhone,
      address: state.address,
      documentId: state.signedDocumentId,
      password: password,
    );
  }

  bool _isAlreadyCreatedError(String message) {
    final normalized = message.trim().toLowerCase();
    return normalized.contains('duplic') ||
        normalized.contains('already') ||
        normalized.contains('ya existe') ||
        normalized.contains('ya esta') ||
        normalized.contains('registrado');
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return RegistrationMessage(
        onContinue: _resultErrorMessage == null ? widget.onContinue : null,
        onRetry: _resultErrorMessage != null ? _handleRetry : null,
        errorMessage: _resultErrorMessage,
      );
    }

    return FourthStepForm(
      onContinue: _handleContinue,
      onBack: widget.onBack,
      isLoading: _isSavingPassword,
    );
  }
}
