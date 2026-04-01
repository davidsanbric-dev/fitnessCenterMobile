import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:scribble/scribble.dart';

class SignedTermsPdfBuilder {
  static const String _termsAssetPath =
      'assets/register_terms_and_conditions.md';
  static const double _pageWidth = 595.0;
  static const double _pageHeight = 842.0;
  static const double _marginLeft = 40.0;
  static const double _textTop = 800.0;
  static const double _lineHeight = 14.0;
  static const int _maxLinesPerPage = 34;
  static const double _signatureBoxLeft = 60.0;
  static const double _signatureBoxBottom = 110.0;
  static const double _signatureBoxWidth = 220.0;
  static const double _signatureBoxHeight = 90.0;

  Future<Uint8List> buildSignedTermsPdf({
    required List<SketchLine> signatureLines,
    required String signerName,
    required String signerEmail,
    DateTime? signedAt,
  }) async {
    if (signatureLines.isEmpty) {
      throw StateError('No signature was found to generate the document.');
    }

    final termsMarkdown = await rootBundle.loadString(_termsAssetPath);
    final normalizedTerms = _normalizeMarkdown(termsMarkdown);
    final wrappedLines = _wrapLines(normalizedTerms);
    final pagedLines = _paginateLines(wrappedLines, _maxLinesPerPage);
    final effectiveSignedAt = signedAt ?? DateTime.now();
    final pageContents = <String>[];

    for (int index = 0; index < pagedLines.length; index++) {
      final isLastPage = index == pagedLines.length - 1;
      pageContents.add(
        _buildPageContent(
          lines: pagedLines[index],
          includeSignature: isLastPage,
          signatureLines: signatureLines,
          signerName: signerName,
          signerEmail: signerEmail,
          signedAt: effectiveSignedAt,
        ),
      );
    }

    return _buildPdfDocument(pageContents);
  }

  List<String> _normalizeMarkdown(String markdown) {
    final result = <String>[];
    for (final rawLine in markdown.split('\n')) {
      var line = rawLine.trimRight();
      if (line.trim().isEmpty) {
        result.add('');
        continue;
      }

      if (line.startsWith('#')) {
        line = line.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      } else if (line.startsWith('- ')) {
        line = ' - ${line.substring(2).trim()}';
      }
      result.add(line);
    }
    return result;
  }

  List<String> _wrapLines(List<String> lines) {
    final wrapped = <String>[];
    const int maxChars = 90;

    for (final line in lines) {
      final trimmed = line.trimRight();
      if (trimmed.isEmpty) {
        wrapped.add('');
        continue;
      }
      if (trimmed.length <= maxChars) {
        wrapped.add(trimmed);
        continue;
      }

      final words = trimmed.split(RegExp(r'\s+'));
      final buffer = StringBuffer();
      for (final word in words) {
        final current = buffer.toString();
        final candidate = current.isEmpty ? word : '$current $word';
        if (candidate.length > maxChars) {
          wrapped.add(current);
          buffer
            ..clear()
            ..write(word);
        } else {
          buffer
            ..clear()
            ..write(candidate);
        }
      }
      final rest = buffer.toString();
      if (rest.isNotEmpty) {
        wrapped.add(rest);
      }
    }

    return wrapped;
  }

  List<List<String>> _paginateLines(List<String> lines, int linesPerPage) {
    if (lines.isEmpty) {
      return [<String>[]];
    }

    final pages = <List<String>>[];
    for (int index = 0; index < lines.length; index += linesPerPage) {
      final end = (index + linesPerPage < lines.length)
          ? index + linesPerPage
          : lines.length;
      pages.add(lines.sublist(index, end));
    }
    return pages;
  }

  String _buildPageContent({
    required List<String> lines,
    required bool includeSignature,
    required List<SketchLine> signatureLines,
    required String signerName,
    required String signerEmail,
    required DateTime signedAt,
  }) {
    final buffer = StringBuffer()
      ..writeln('BT')
      ..writeln('/F1 11 Tf')
      ..writeln('${_f(_lineHeight)} TL')
      ..writeln('${_f(_marginLeft)} ${_f(_textTop)} Td');

    for (final line in lines) {
      buffer.writeln('(${_pdfEscape(line)}) Tj');
      buffer.writeln('T*');
    }

    buffer.writeln('ET');

    if (!includeSignature) {
      return buffer.toString();
    }

    buffer
      ..writeln('0.2 w')
      ..writeln(
        '${_f(_signatureBoxLeft)} ${_f(_signatureBoxBottom)} ${_f(_signatureBoxWidth)} ${_f(_signatureBoxHeight)} re',
      )
      ..writeln('S')
      ..writeln('BT')
      ..writeln('/F1 10 Tf')
      ..writeln('12 TL')
      ..writeln('${_f(_signatureBoxLeft)} ${_f(_signatureBoxBottom - 20)} Td')
      ..writeln('(Firmante: ${_pdfEscape(signerName.trim())}) Tj')
      ..writeln('T*')
      ..writeln('(Correo: ${_pdfEscape(signerEmail.trim())}) Tj')
      ..writeln('T*')
      ..writeln('(Fecha firma: ${_pdfEscape(_formatDate(signedAt))}) Tj')
      ..writeln('ET')
      ..write(_buildSignatureStrokes(signatureLines));

    return buffer.toString();
  }

  String _buildSignatureStrokes(List<SketchLine> lines) {
    final allPoints = lines.expand((line) => line.points).toList();
    if (allPoints.isEmpty) {
      return '';
    }

    double minX = allPoints.first.x;
    double maxX = allPoints.first.x;
    double minY = allPoints.first.y;
    double maxY = allPoints.first.y;

    for (final point in allPoints) {
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.y > maxY) maxY = point.y;
    }

    final rangeX = (maxX - minX).abs() < 0.001 ? 1.0 : (maxX - minX);
    final rangeY = (maxY - minY).abs() < 0.001 ? 1.0 : (maxY - minY);
    final drawBuffer = StringBuffer()..writeln('0 0 0 RG');

    for (final line in lines) {
      if (line.points.length < 2) {
        continue;
      }
      final scaledWidth = (line.width * 0.4).clamp(0.8, 2.4);
      drawBuffer.writeln('${_f(scaledWidth)} w');

      final first = line.points.first;
      final firstX =
          _signatureBoxLeft + ((first.x - minX) / rangeX) * _signatureBoxWidth;
      final firstY =
          _signatureBoxBottom +
          _signatureBoxHeight -
          ((first.y - minY) / rangeY) * _signatureBoxHeight;
      drawBuffer.writeln('${_f(firstX)} ${_f(firstY)} m');

      for (int index = 1; index < line.points.length; index++) {
        final point = line.points[index];
        final pointX =
            _signatureBoxLeft +
            ((point.x - minX) / rangeX) * _signatureBoxWidth;
        final pointY =
            _signatureBoxBottom +
            _signatureBoxHeight -
            ((point.y - minY) / rangeY) * _signatureBoxHeight;
        drawBuffer.writeln('${_f(pointX)} ${_f(pointY)} l');
      }

      drawBuffer.writeln('S');
    }

    return drawBuffer.toString();
  }

  Uint8List _buildPdfDocument(List<String> pageContents) {
    final pageCount = pageContents.length;
    final fontObjectId = 3 + pageCount * 2;
    final maxObjectId = fontObjectId;
    final objects = <int, Uint8List>{};
    final pageObjectIds = <int>[];

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      final pageObjectId = 3 + pageIndex * 2;
      final contentObjectId = pageObjectId + 1;
      pageObjectIds.add(pageObjectId);

      final contentBytes = _encodePdf(pageContents[pageIndex]);
      final streamHeader = _encodePdf(
        '<< /Length ${contentBytes.length} >>\nstream\n',
      );
      final streamFooter = _encodePdf('\nendstream');
      final streamObject = BytesBuilder()
        ..add(streamHeader)
        ..add(contentBytes)
        ..add(streamFooter);
      objects[contentObjectId] = streamObject.toBytes();

      objects[pageObjectId] = _encodePdf(
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ${_f(_pageWidth)} ${_f(_pageHeight)}] /Resources << /Font << /F1 $fontObjectId 0 R >> >> /Contents $contentObjectId 0 R >>',
      );
    }

    final kids = pageObjectIds.map((id) => '$id 0 R').join(' ');
    objects[2] = _encodePdf(
      '<< /Type /Pages /Kids [$kids] /Count $pageCount >>',
    );
    objects[1] = _encodePdf('<< /Type /Catalog /Pages 2 0 R >>');
    objects[fontObjectId] = _encodePdf(
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    );

    final fileBytes = BytesBuilder();
    fileBytes.add(_encodePdf('%PDF-1.4\n%âãÏÓ\n'));
    final offsets = List<int>.filled(maxObjectId + 1, 0);

    for (int objectId = 1; objectId <= maxObjectId; objectId++) {
      final objectData = objects[objectId];
      if (objectData == null) {
        continue;
      }
      offsets[objectId] = fileBytes.length;
      fileBytes.add(_encodePdf('$objectId 0 obj\n'));
      fileBytes.add(objectData);
      fileBytes.add(_encodePdf('\nendobj\n'));
    }

    final xrefOffset = fileBytes.length;
    fileBytes.add(_encodePdf('xref\n0 ${maxObjectId + 1}\n'));
    fileBytes.add(_encodePdf('0000000000 65535 f \n'));

    for (int objectId = 1; objectId <= maxObjectId; objectId++) {
      final offset = offsets[objectId];
      final paddedOffset = offset.toString().padLeft(10, '0');
      fileBytes.add(_encodePdf('$paddedOffset 00000 n \n'));
    }

    fileBytes.add(
      _encodePdf(
        'trailer\n<< /Size ${maxObjectId + 1} /Root 1 0 R >>\nstartxref\n$xrefOffset\n%%EOF',
      ),
    );

    return fileBytes.toBytes();
  }

  String _formatDate(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  String _pdfEscape(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('(', r'\(')
        .replaceAll(')', r'\)')
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ');
  }

  Uint8List _encodePdf(String value) {
    final bytes = <int>[];
    for (final rune in value.runes) {
      if (rune <= 0xFF) {
        bytes.add(rune);
      } else {
        bytes.add(0x3F);
      }
    }
    return Uint8List.fromList(bytes);
  }

  String _f(double value) => value.toStringAsFixed(2);
}
