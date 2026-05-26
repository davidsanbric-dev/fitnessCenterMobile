import 'dart:convert';
import 'dart:typed_data';

import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:pdfx/pdfx.dart';

/// Dialog that renders a PDF-like viewer for medical orders, accepting either
/// an asset/file path or a base64 PDF code.
class DocumentViewerDialog extends StatefulWidget {
  const DocumentViewerDialog({
    super.key,
    required this.title,
    this.urlPath,
    this.pdfCode,
  });

  final String title;
  final String? urlPath;
  final String? pdfCode;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? urlPath,
    String? pdfCode,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => DocumentViewerDialog(
        title: title,
        urlPath: urlPath,
        pdfCode: pdfCode,
      ),
    );
  }

  @override
  State<DocumentViewerDialog> createState() => _DocumentViewerDialogState();
}

class _DocumentViewerDialogState extends State<DocumentViewerDialog> {
  PdfControllerPinch? _pdfController;
  bool _isLoading = true;
  String? _error;
  static const double _minZoom = 0.5;
  static const double _maxZoom = 5.0;
  static const double _zoomStep = 1.15;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _initPdf() async {
    final path = widget.urlPath?.trim() ?? '';
    final code = widget.pdfCode?.trim() ?? '';

    if (path.isEmpty && code.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'No content associated with this document was found.';
      });
      return;
    }

    try {
      final documentFuture = _openDocument(path: path, pdfCode: code);
      await documentFuture; // ensure early failure surfaces to the UI
      setState(() {
        _pdfController = PdfControllerPinch(document: documentFuture);
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _error = 'Could not load the document: $err';
        _isLoading = false;
      });
    }
  }

  Future<PdfDocument> _openDocument({
    required String path,
    required String pdfCode,
  }) async {
    final sanitizedPath = path.trim();
    final sanitizedPdfCode = pdfCode.trim();

    if (sanitizedPath.isNotEmpty) {
      final isProbablyAsset =
          !sanitizedPath.startsWith('/') && !sanitizedPath.contains('://');

      if (isProbablyAsset) {
        try {
          return await PdfDocument.openAsset(sanitizedPath);
        } catch (_) {
          // If the asset is not bundled, try the file system fallback below.
        }
      }

      try {
        return await PdfDocument.openFile(sanitizedPath);
      } catch (_) {
        if (sanitizedPdfCode.isEmpty) {
          throw Exception('File not found at $sanitizedPath');
        }
      }
    }

    if (sanitizedPdfCode.isEmpty) {
      throw Exception('No content found for this document.');
    }

    final decoded = Uint8List.fromList(base64Decode(sanitizedPdfCode));
    return PdfDocument.openData(decoded);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _pdfController;
    final content = SizedBox(
      width: 520,
      height: 600,
      child: _buildBody(controller),
    );

    return AlertDialog(
      title: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(color: AppTheme.brandBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(PdfControllerPinch? controller) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final errorMessage = _error?.trim();
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage, textAlign: TextAlign.center));
    }

    if (controller == null) {
      return const Center(
        child: Text('Could not initialize the document viewer.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildControls(controller),
        const SizedBox(height: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PdfViewPinch(
              controller: controller,
              backgroundDecoration: BoxDecoration(color: Colors.grey.shade200),
              onDocumentError: (error) {
                setState(() => _error = 'Rendering error: $error');
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(PdfControllerPinch controller) {
    final zoomPercent = (controller.zoomRatio * 100).clamp(
      (_minZoom * 100),
      (_maxZoom * 100),
    );

    return Row(
      children: [
        IconButton(
          onPressed: () => _changeZoom(controller, 1 / _zoomStep),
          icon: const Icon(LucideIcons.zoomOut),
          tooltip: 'Alejar',
        ),
        IconButton(
          onPressed: () => _fitToWidth(controller),
          icon: const Icon(LucideIcons.maximize),
          tooltip: 'Ajustar a ancho',
        ),
        IconButton(
          onPressed: () => _changeZoom(controller, _zoomStep),
          icon: const Icon(LucideIcons.zoomIn),
          tooltip: 'Acercar',
        ),
        const SizedBox(width: 12),
        Text(
          '${zoomPercent.toStringAsFixed(0)}%',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _changeZoom(PdfControllerPinch controller, double factor) {
    final current = controller.zoomRatio;
    final target = (current * factor).clamp(_minZoom, _maxZoom);
    final appliedFactor = target / (current == 0 ? 1 : current);
    final matrix = controller.value.clone()
      ..scaleByDouble(appliedFactor, appliedFactor, 1.0, 1.0);
    controller.value = matrix;
    setState(() {});
  }

  Future<void> _fitToWidth(PdfControllerPinch controller) async {
    final matrix = controller.calculatePageFitMatrix(
      pageNumber: controller.page,
    );
    if (matrix != null) {
      await controller.goTo(destination: matrix);
      setState(() {});
    }
  }
}
