import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/api/document_api.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/services/signed_terms_pdf_builder.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_bloc.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_event.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/identity_verification_message.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/second_step_form.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/signing_frame.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/terms_and_conditions_box.dart';
import 'package:get/get.dart';

enum _DialogStep { identityForm, identityResult, terms }

class TermsSigningResult {
  const TermsSigningResult({required this.isSuccess, this.errorMessage});

  const TermsSigningResult.success() : this(isSuccess: true);

  const TermsSigningResult.failure(String message)
    : this(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
}

class TermsAndConditionsDialog extends StatefulWidget {
  const TermsAndConditionsDialog({super.key});

  static Future<TermsSigningResult?> show(BuildContext context) {
    final bloc = context.read<RegisterBloc>();
    return showDialog<TermsSigningResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const TermsAndConditionsDialog(),
      ),
    );
  }

  @override
  State<TermsAndConditionsDialog> createState() =>
      _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  _DialogStep _step = _DialogStep.identityForm;
  bool _isIdentityVerified = false;
  String? _identityVerificationMessage;
  final EnsureRegisterEmailSessionUseCase _ensureRegisterEmailSessionUseCase =
      Get.find<EnsureRegisterEmailSessionUseCase>();
  final DocumentApi _documentApi = DocumentApi();
  final SignedTermsPdfBuilder _signedTermsPdfBuilder = SignedTermsPdfBuilder();


  void _showIdentityResult({required bool isSuccess, String? message}) {
    if (_step != _DialogStep.identityForm) {
      return;
    }
    setState(() {
      _isIdentityVerified = isSuccess;
      _identityVerificationMessage = message;
      _step = _DialogStep.identityResult;
    });
  }

  void _continueFromIdentityResult() {
    if (_isIdentityVerified) {
      _openTerms();
      return;
    }

    setState(() {
      _identityVerificationMessage = null;
      _step = _DialogStep.identityForm;
    });
  }

  void _openTerms() {
    if (_step == _DialogStep.terms) {
      return;
    }

    setState(() {
      _step = _DialogStep.terms;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RegisterBloc>().add(const RegisterTermsOpened());
        context.read<RegisterBloc>().add(
          const RegisterSignedDocumentIdChanged(''),
        );
      }
    });
  }

  Future<SigningFrameResult> _uploadSignedTermsDocument(
    SignatureCaptureData signatureData,
  ) async {
    if (signatureData.lines.isEmpty) {
      return const SigningFrameResult.failure(
        'You must provide a valid signature.',
      );
    }

    final registerState = context.read<RegisterBloc>().state;
    try {
      await _ensureRegisterEmailSessionUseCase(email: registerState.email);
      final pdfBytes = await _signedTermsPdfBuilder.buildSignedTermsPdf(
        signatureLines: signatureData.lines,
        signerName: _buildSignerName(),
        signerEmail: registerState.email,
      );
      final documentId = await _documentApi.uploadDocument(
        fileBytes: pdfBytes,
        fileName: _buildTermsFileName(),
      );
      return SigningFrameResult.success(documentId: documentId);
    } on ApiException catch (error) {
      final message = error.message.trim();
      return SigningFrameResult.failure(
        message.isEmpty ? 'Could not upload the signed document.' : message,
      );
    } catch (error) {
      return SigningFrameResult.failure(
        'Could not generate or upload the signed document: $error',
      );
    }
  }

  String _buildSignerName() {
    final state = context.read<RegisterBloc>().state;
    final nameParts = [
      state.firstName,
      state.paternalSurname,
      state.maternalSurname,
    ].map((part) => part.trim()).where((part) => part.isNotEmpty).toList();
    if (nameParts.isNotEmpty) {
      return nameParts.join(' ');
    }
    final email = state.email.trim();
    return email.isNotEmpty ? email : 'Usuario FitnessCenter';
  }

  String _buildTermsFileName() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return 'signed_terms_$year$month${day}_$hour$minute$second.pdf';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double maxHeight = size.height * 0.75;
    final bool hasReachedBottom = context.select<RegisterBloc, bool>(
      (bloc) => bloc.state.hasReachedTermsEnd,
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_step == _DialogStep.identityForm) ...[
                SecondStepForm(onVerify: _showIdentityResult),
              ] else if (_step == _DialogStep.identityResult) ...[
                IdentityVerificationMessage(
                  isSuccess: _isIdentityVerified,
                  message: _identityVerificationMessage,
                  onContinue: _continueFromIdentityResult,
                ),
              ] else ...[
                const Expanded(child: TermsAndConditionsBox()),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<RegisterBloc>().add(
                            const RegisterTermsSigned(hasSigned: false),
                          );
                          context.read<RegisterBloc>().add(
                            const RegisterSignedDocumentIdChanged(''),
                          );
                          Navigator.of(context).pop();
                        },
                        style: AppTheme.dialogOutlinedButtonStyle(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: hasReachedBottom
                            ? () async {
                                final frameResult =
                                    await SigningFrameDialog.show(
                                      context,
                                      onConfirmSignature:
                                          _uploadSignedTermsDocument,
                                    );
                                if (!context.mounted) return;
                                if (frameResult == null) {
                                  context.read<RegisterBloc>().add(
                                    const RegisterTermsSigned(hasSigned: false),
                                  );
                                  return;
                                }
                                if (frameResult.isSuccess) {
                                  final String documentId =
                                      frameResult.documentId?.trim() ?? '';
                                  context.read<RegisterBloc>().add(
                                    const RegisterTermsSigned(hasSigned: true),
                                  );
                                  context.read<RegisterBloc>().add(
                                    RegisterSignedDocumentIdChanged(documentId),
                                  );
                                  Navigator.of(
                                    context,
                                  ).pop(const TermsSigningResult.success());
                                } else {
                                  context.read<RegisterBloc>().add(
                                    const RegisterTermsSigned(hasSigned: false),
                                  );
                                  context.read<RegisterBloc>().add(
                                    const RegisterSignedDocumentIdChanged(''),
                                  );
                                  Navigator.of(context).pop(
                                    TermsSigningResult.failure(
                                      frameResult.errorMessage
                                                  ?.trim()
                                                  .isEmpty ??
                                              true
                                          ? 'No fue posible completar la firma.'
                                          : frameResult.errorMessage!.trim(),
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: AppTheme.dialogPrimaryButtonStyle(),
                        child: const Text('Firmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
