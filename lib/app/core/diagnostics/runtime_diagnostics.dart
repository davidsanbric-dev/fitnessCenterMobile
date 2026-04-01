import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RuntimeDiagnostics {
  RuntimeDiagnostics._();

  static final List<String> _events = <String>[];
  static final Set<String> _reportedMissingAssets = <String>{};
  static const int _maxEvents = 500;
  static bool _installed = false;
  static AppLifecycleState? _lastLifecycleState;

  static AppLifecycleState? get currentLifecycleState => _lastLifecycleState;

  static void installGlobalHandlers() {
    if (_installed) {
      return;
    }
    _installed = true;

    WidgetsBinding.instance.addObserver(_LifecycleObserver());
    _lastLifecycleState = WidgetsBinding.instance.lifecycleState;
    breadcrumb(
      'lifecycle-initial',
      data: 'state=${_lastLifecycleState?.name ?? '-'}',
    );

    final previousFlutterOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exceptionAsString();
      final stack = details.stack?.toString().split('\n').take(5).join(' | ');
      breadcrumb(
        'flutter-error',
        data: 'exception=$exception stack=${stack ?? '-'}',
      );
      previousFlutterOnError?.call(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      breadcrumb(
        'platform-error',
        data:
            'error=$error stack=${stack.toString().split('\n').take(6).join(' | ')}',
      );
      return false;
    };

    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        final buildMs = timing.buildDuration.inMilliseconds;
        final rasterMs = timing.rasterDuration.inMilliseconds;
        if (buildMs >= 32 || rasterMs >= 32) {
          breadcrumb(
            'slow-frame',
            data:
                'buildMs=$buildMs rasterMs=$rasterMs totalMs=${timing.totalSpan.inMilliseconds}',
          );
        }
      }
    });

    breadcrumb('diagnostics-installed');
  }

  static void breadcrumb(String event, {String? data}) {
    final line =
        '${DateTime.now().toIso8601String()} [DIAG] $event${data == null ? '' : ' $data'}';
    _events.add(line);
    if (_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }
    if (kDebugMode) {
      debugPrint(line);
    }
  }

  static String dump({int limit = 200}) {
    if (_events.isEmpty) {
      return 'No diagnostics breadcrumbs captured.';
    }
    final start = _events.length > limit ? _events.length - limit : 0;
    return _events.sublist(start).join('\n');
  }

  static void missingAsset(String assetPath, {String? scope, Object? error}) {
    final key = '${scope ?? '-'}::$assetPath';
    if (!_reportedMissingAssets.add(key)) {
      return;
    }
    final safeScope = scope ?? '-';
    final safeError = error?.toString() ?? '-';
    breadcrumb(
      'asset-missing',
      data: 'scope=$safeScope path=$assetPath error=$safeError',
    );
  }

  static void resourceWarning(String event, {String? data}) {
    breadcrumb('resource-warning/$event', data: data);
  }
}

class _LifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    RuntimeDiagnostics._lastLifecycleState = state;
    RuntimeDiagnostics.breadcrumb(
      'lifecycle-change',
      data: 'state=${state.name}',
    );
  }
}

class RuntimeRouteObserver extends NavigatorObserver {
  void _record(String event, Route<dynamic>? route, Route<dynamic>? previous) {
    RuntimeDiagnostics.breadcrumb(
      event,
      data:
          'route=${route?.settings.name ?? '-'} previous=${previous?.settings.name ?? '-'}',
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('route-push', route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('route-pop', route, previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('route-remove', route, previousRoute);
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    RuntimeDiagnostics.breadcrumb(
      'route-replace',
      data:
          'new=${newRoute?.settings.name ?? '-'} old=${oldRoute?.settings.name ?? '-'}',
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
