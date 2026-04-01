import 'dart:async';

import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:get/get.dart';

abstract class ControllerBase extends GetxController {
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  Future<T?> runLoading<T>({
    required Future<T> Function() action,
    required String errorMessage,
    RxBool? loading,
    RxnString? errorTarget,
    FutureOr<void> Function(T result)? onSuccess,
    FutureOr<void> Function()? onError,
    bool rethrowOnError = false,
    bool clearError = true,
  }) async {
    final loadingState = loading ?? isLoading;
    final errorState = errorTarget ?? error;

    loadingState.value = true;
    if (clearError) {
      errorState.value = null;
    }

    try {
      final result = await action();
      if (onSuccess != null) {
        await onSuccess(result);
      }
      return result;
    } catch (err, stackTrace) {
      errorState.value = err.userErrorMessageWith(errorMessage);
      if (onError != null) {
        await onError();
      }
      if (rethrowOnError) {
        if (err is ApiException) {
          rethrow;
        }
        Error.throwWithStackTrace(
          ApiException(errorState.value ?? errorMessage),
          stackTrace,
        );
      }
    } finally {
      loadingState.value = false;
    }
    return null;
  }

  Future<T?> runLatestLoadOperation<T>({
    RxBool? isLoading,
    RxnString? error,
    required Future<T> Function() loader,
    FutureOr<void> Function(T result)? onSuccess,
    FutureOr<void> Function()? onError,
    required String unexpectedErrorMessage,
    required int Function() startSequence,
    required bool Function(int sequence) shouldApplyResult,
    bool rethrowOnError = false,
  }) async {
    final loadingState = isLoading ?? this.isLoading;
    final errorState = error ?? this.error;
    final sequence = startSequence();
    bool isCurrent() => shouldApplyResult(sequence);

    loadingState.value = true;
    errorState.value = null;

    try {
      final result = await loader();
      if (!isCurrent()) {
        return null;
      }
      if (onSuccess != null) {
        await onSuccess(result);
      }
      return result;
    } catch (err, stackTrace) {
      if (!isCurrent()) {
        return null;
      }
      final message = err is ApiException
          ? err.message
          : '$unexpectedErrorMessage: $err';
      errorState.value = message;
      if (onError != null) {
        await onError();
      }
      if (rethrowOnError) {
        if (err is ApiException) {
          rethrow;
        }
        Error.throwWithStackTrace(ApiException(message), stackTrace);
      }
    } finally {
      if (isCurrent()) {
        loadingState.value = false;
      }
    }
    return null;
  }

  void resetState({RxBool? loading, RxnString? errorTarget}) {
    final loadingState = loading ?? isLoading;
    final errorState = errorTarget ?? error;
    loadingState.value = false;
    errorState.value = null;
  }
}

extension ErrorMessageExtension on Object {
  String get userErrorMessage => switch (this) {
    ApiException(message: final msg) => msg,
    _ => 'Error inesperado: $this',
  };

  String userErrorMessageWith(String prefix) => switch (this) {
    ApiException(message: final msg) => msg,
    _ => '$prefix: $this',
  };
}
