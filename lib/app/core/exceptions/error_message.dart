import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';

/// Maps any thrown [Object] to a user-facing message: an [ApiException]'s
/// message verbatim, otherwise a prefixed description of the raw error.
///
/// Shared across the `ChangeNotifier` view-models (directly and via
/// `ViewModelBase`) so they surface backend failures identically.
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
