import 'dart:async';

import 'package:fitnesscenter_mobile/app/core/exceptions/error_message.dart';
import 'package:flutter/foundation.dart';

/// ChangeNotifier-based equivalent of the GetX `ControllerBase` load helper.
///
/// Instead of mutating `RxBool`/`RxnString` state, callers pass `setLoading` /
/// `setError` callbacks that update plain fields; this base calls
/// [notifyListeners] around them so a `ListenableBuilder` rebuilds.
abstract class ViewModelBase extends ChangeNotifier {
  /// Runs a one-shot [loader], toggling loading/error around it and notifying
  /// listeners so a `ListenableBuilder` rebuilds. Centralizes the
  /// `set loading → try → on error format → finally clear loading` boilerplate
  /// the simple list-load view-models would otherwise hand-roll.
  ///
  /// On failure, [setError] receives the [ApiException] message or, for any
  /// other error, `'<unexpectedErrorMessage>: <error>'`.
  Future<T?> runLoad<T>({
    required void Function(bool isLoading) setLoading,
    required void Function(String? message) setError,
    required Future<T> Function() loader,
    required String unexpectedErrorMessage,
    FutureOr<void> Function(T result)? onSuccess,
    FutureOr<void> Function()? onError,
  }) {
    return runLatestLoadOperation<T>(
      setLoading: setLoading,
      setError: setError,
      loader: loader,
      onSuccess: onSuccess,
      onError: onError,
      unexpectedErrorMessage: unexpectedErrorMessage,
      // No sequence guarding: a one-shot load is always the current operation.
      startSequence: () => 0,
      shouldApplyResult: (_) => true,
    );
  }

  /// Runs [loader] as the latest operation in a sequence, applying the result
  /// only if it is still current (guards against out-of-order responses).
  Future<T?> runLatestLoadOperation<T>({
    required void Function(bool isLoading) setLoading,
    required void Function(String? message) setError,
    required Future<T> Function() loader,
    required String unexpectedErrorMessage,
    required int Function() startSequence,
    required bool Function(int sequence) shouldApplyResult,
    FutureOr<void> Function(T result)? onSuccess,
    FutureOr<void> Function()? onError,
  }) async {
    final sequence = startSequence();
    bool isCurrent() => shouldApplyResult(sequence);

    setLoading(true);
    setError(null);
    notifyListeners();

    try {
      final result = await loader();
      if (!isCurrent()) {
        return null;
      }
      if (onSuccess != null) {
        await onSuccess(result);
      }
      return result;
    } catch (err) {
      if (!isCurrent()) {
        return null;
      }
      setError(err.userErrorMessageWith(unexpectedErrorMessage));
      if (onError != null) {
        await onError();
      }
    } finally {
      if (isCurrent()) {
        setLoading(false);
        notifyListeners();
      }
    }
    return null;
  }
}
