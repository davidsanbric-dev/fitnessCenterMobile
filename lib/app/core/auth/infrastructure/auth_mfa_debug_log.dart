import 'dart:collection';

import 'package:portfolio_mobile_app/app/core/utils/format/input.dart';
import 'package:portfolio_mobile_app/firebase_options.dart';
import 'package:flutter/foundation.dart';

class AuthMfaDebugLog {
  AuthMfaDebugLog._();

  static const int _maxEntries = 300;
  static final AuthMfaDebugLog _instance = AuthMfaDebugLog._();
  final ListQueue<String> _entries = ListQueue<String>();

  static void record(String message) => _instance._record(message);

  void _record(String message) {
    if (!kDebugMode) {
      return;
    }
    final line = '${DateTime.now().toIso8601String()} $message';
    if (_entries.length >= _maxEntries) {
      _entries.removeFirst();
    }
    _entries.addLast(line);
    debugPrint(line);
  }

  static void recordEvent({
    required String scope,
    required String event,
    Map<String, Object?> fields = const <String, Object?>{},
  }) => _instance._recordEvent(scope: scope, event: event, fields: fields);

  static void recordMfaEvent({
    required String flow,
    required String event,
    String? traceId,
    String? phoneNumber,
    String? factorUid,
    String? verificationId,
    int? resendToken,
    String? exceptionCode,
    String? exceptionMessage,
    String? currentUserUid,
  }) {
    recordEvent(
      scope: 'MFA/$flow',
      event: event,
      fields: <String, Object?>{
        'trace': _orDash(traceId),
        'phone': maskPhone(phoneNumber),
        'factor': _shortenId(factorUid),
        'verification': _shortenId(verificationId),
        'resend': resendToken ?? '-',
        'code': _orDash(exceptionCode),
        'message': _orDash(exceptionMessage),
        'user': _shortenId(currentUserUid),
        'project': firebaseProjectIdForLogs(),
        'app': firebaseAppNameForLogs(),
        'platform': defaultTargetPlatform.name,
      },
    );
  }

  static String resolverHintTypes(Iterable<String> factorIds) {
    final types = factorIds
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (types.isEmpty) {
      return '-';
    }
    return types.join(',');
  }

  void _recordEvent({
    required String scope,
    required String event,
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    final buffer = StringBuffer('[$scope] $event');
    fields.forEach((key, value) {
      if (value == null) {
        return;
      }
      final normalized = _normalize(value);
      if (normalized.isEmpty) {
        return;
      }
      buffer.write(' $key=$normalized');
    });
    record(buffer.toString());
  }

  static List<String> recent({int limit = 200}) =>
      _instance._recent(limit: limit);

  List<String> _recent({int limit = 200}) {
    final effectiveLimit = limit < 1 ? 1 : limit;
    if (_entries.isEmpty) {
      return const <String>[];
    }
    final start = _entries.length > effectiveLimit
        ? _entries.length - effectiveLimit
        : 0;
    final result = <String>[];
    var index = 0;
    for (final line in _entries) {
      if (index >= start) {
        result.add(line);
      }
      index++;
    }
    return result;
  }

  static String dump({int limit = 200}) => _instance._dump(limit: limit);

  String _dump({int limit = 200}) {
    final lines = recent(limit: limit);
    if (lines.isEmpty) {
      return 'No MFA debug logs captured yet.';
    }
    return lines.join('\n');
  }

  static void clear() => _instance._clear();

  void _clear() {
    _entries.clear();
    if (kDebugMode) {
      debugPrint('${DateTime.now().toIso8601String()} [MFA/DEBUG] cleared');
    }
  }

  static String _normalize(Object value) {
    final text = value.toString().replaceAll('\n', ' ').trim();
    if (text.isEmpty) {
      return '';
    }
    return text;
  }

  static String _shortenId(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return '-';
    }
    if (normalized.length <= 10) {
      return normalized;
    }
    return '${normalized.substring(0, 6)}...${normalized.substring(normalized.length - 4)}';
  }

  static String _orDash(String? value) {
    final normalized = value?.replaceAll('\n', ' ').trim() ?? '';
    if (normalized.isEmpty) {
      return '-';
    }
    return normalized;
  }
}
