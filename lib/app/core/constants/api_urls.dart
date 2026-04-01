import 'package:portfolio_mobile_app/app/core/constants/app_strings.dart';

mixin ApiUrls {
  static String get _apiV1BaseUrl => '${AppStrings.baseUrl}/api/v1';

  static String get authUrl => '$_apiV1BaseUrl/auth';
  static String get usersUrl => '$_apiV1BaseUrl/users';
  static String get homeUrl => '$_apiV1BaseUrl/home';
  static String get bookingsUrl => '$_apiV1BaseUrl/bookings';
  static String get staticsUrl => '$_apiV1BaseUrl/statics';
  static String get slotsUrl => '$_apiV1BaseUrl/slots';
  static String get trainersUrl => '$_apiV1BaseUrl/trainers';
  static String get disciplinesUrl => '$_apiV1BaseUrl/disciplines';
  static String get classCategoriesUrl => '$_apiV1BaseUrl/class-categories';
  static String get classTypesUrl => '$_apiV1BaseUrl/class-types';
  static String get membershipPlansUrl => '$_apiV1BaseUrl/membership-plans';
  static String get notificationsUrl => '$_apiV1BaseUrl/notifications';
  static String get devicesUrl => '$_apiV1BaseUrl/devices';
  static String get documentsUrl => _apiV1BaseUrl;
}
