import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';

/// Registers this device's FCM token with the backend so the API can push
/// company-scoped notifications (e.g. new blog posts) to it. Idempotent on the
/// server: re-posting the same token updates it in place.
class DevicesApi extends ApiBase {
  Future<bool> registerDevice({
    required String token,
    String platform = 'android',
  }) async {
    try {
      await createAsync<void>(
        url: ApiUrls.devicesUrl,
        requestBody: <String, dynamic>{'token': token, 'platform': platform},
        requestErrorMessage: 'Unable to register device for notifications',
      );
      return true;
    } catch (_) {
      // Non-critical: notifications simply won't reach a device that failed to
      // register. Never surface this to the user.
      return false;
    }
  }
}
