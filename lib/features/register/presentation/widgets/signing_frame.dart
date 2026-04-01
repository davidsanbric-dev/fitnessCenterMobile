import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:scribble/scribble.dart';

class SignatureCaptureData {
  const SignatureCaptureData({
    required this.signatureImageBytes,
    required this.lines,
    required this.canvasSize,
  });

  final ByteData signatureImageBytes;
  final List<SketchLine> lines;
  final Size canvasSize;
}

class SigningFrameResult {
  const SigningFrameResult({
    required this.isSuccess,
    this.errorMessage,
    this.documentId,
  });

  const SigningFrameResult.success({String? documentId})
    : this(isSuccess: true, documentId: documentId);

  const SigningFrameResult.failure(String message)
    : this(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
  final String? documentId;
}

class SigningFrameDialog extends StatefulWidget {
  const SigningFrameDialog({
    super.key,
    this.onExported,
    this.onConfirmSignature,
  });

  final void Function(ByteData bytes)? onExported;
  final Future<SigningFrameResult> Function(SignatureCaptureData data)?
  onConfirmSignature;

  static Future<SigningFrameResult?> show(
    BuildContext context, {
    void Function(ByteData bytes)? onExported,
    Future<SigningFrameResult> Function(SignatureCaptureData data)?
    onConfirmSignature,
  }) {
    return showDialog<SigningFrameResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SigningFrameDialog(
        onExported: onExported,
        onConfirmSignature: onConfirmSignature,
      ),
    );
  }

  @override
  State<SigningFrameDialog> createState() => _SigningFrameDialogState();
}

class _SigningFrameDialogState extends State<SigningFrameDialog> {
  final ScribbleNotifier _notifier = ScribbleNotifier();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _notifier
      ..setColor(Colors.black87)
      ..setStrokeWidth(2.4);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double maxHeight = size.height * 0.7;

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
              Text(
                'Firma digital',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Firma dentro del recuadro con tu dedo o lapiz.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Scribble(notifier: _notifier),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<ScribbleState>(
                valueListenable: _notifier,
                builder: (context, state, _) {
                  final hasSignature = state.lines.isNotEmpty;
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: hasSignature
                              ? _notifier.clear
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(hasSignature ? 'Borrar' : 'Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: hasSignature && !_isSubmitting
                              ? _handleConfirm
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.brandBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Confirmar firma'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleConfirm() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final signatureImageBytes = await _notifier.renderImage(pixelRatio: 3.0);
      widget.onExported?.call(signatureImageBytes);
      final renderBox =
          _notifier.repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderBox?;
      final canvasSize = renderBox?.size ?? const Size(1, 1);
      final signatureData = SignatureCaptureData(
        signatureImageBytes: signatureImageBytes,
        lines: List<SketchLine>.from(_notifier.value.lines),
        canvasSize: canvasSize,
      );

      final result =
          await widget.onConfirmSignature?.call(signatureData) ??
          const SigningFrameResult.success();
      if (!mounted) {
        return;
      }
      if (!result.isSuccess) {
        Navigator.of(context).pop(result);
        return;
      }

      Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(
        SigningFrameResult.failure('Could not capture the signature. $error'),
      );
    }
  }
}
