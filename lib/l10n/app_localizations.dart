import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Tooltip del botón para volver al paso anterior
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get commonClear;

  /// No description provided for @commonMenu.
  ///
  /// In es, this message translates to:
  /// **'Menú'**
  String get commonMenu;

  /// Botón que reintenta una carga fallida
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// Tooltip del menú de acciones de cada fila
  ///
  /// In es, this message translates to:
  /// **'Acciones de la fila'**
  String get commonRowActions;

  /// No description provided for @commonNoRecords.
  ///
  /// In es, this message translates to:
  /// **'No hay registros disponibles.'**
  String get commonNoRecords;

  /// No description provided for @commonNotSpecified.
  ///
  /// In es, this message translates to:
  /// **'Sin especificar'**
  String get commonNotSpecified;

  /// No description provided for @commonViewProfile.
  ///
  /// In es, this message translates to:
  /// **'Ver perfil'**
  String get commonViewProfile;

  /// No description provided for @authAccessAccount.
  ///
  /// In es, this message translates to:
  /// **'Accede a tu cuenta'**
  String get authAccessAccount;

  /// No description provided for @authEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authEmail;

  /// No description provided for @authEmailHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo'**
  String get authEmailHint;

  /// No description provided for @authPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get authPasswordHint;

  /// No description provided for @authSignIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authSignIn;

  /// No description provided for @authResendVerification.
  ///
  /// In es, this message translates to:
  /// **'Reenviar correo de verificación'**
  String get authResendVerification;

  /// No description provided for @authIHaveVerified.
  ///
  /// In es, this message translates to:
  /// **'Ya verifiqué'**
  String get authIHaveVerified;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido!'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo para continuar'**
  String get authWelcomeSubtitle;

  /// No description provided for @bookingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis reservas'**
  String get bookingsTitle;

  /// No description provided for @bookingsBookSession.
  ///
  /// In es, this message translates to:
  /// **'Reservar una clase'**
  String get bookingsBookSession;

  /// Estado vacío de la lista de reservas del socio
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes reservas.'**
  String get bookingsEmpty;

  /// No description provided for @bookingsColumnTime.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get bookingsColumnTime;

  /// No description provided for @bookingsColumnClassTrainer.
  ///
  /// In es, this message translates to:
  /// **'Clase / Entrenador'**
  String get bookingsColumnClassTrainer;

  /// No description provided for @bookingsColumnActions.
  ///
  /// In es, this message translates to:
  /// **'Acciones'**
  String get bookingsColumnActions;

  /// No description provided for @bookingsTrainerPending.
  ///
  /// In es, this message translates to:
  /// **'Entrenador por asignar'**
  String get bookingsTrainerPending;

  /// No description provided for @bookingsViewDetails.
  ///
  /// In es, this message translates to:
  /// **'Ver detalles'**
  String get bookingsViewDetails;

  /// No description provided for @bookingsConfirmBooking.
  ///
  /// In es, this message translates to:
  /// **'CONFIRMAR RESERVA'**
  String get bookingsConfirmBooking;

  /// No description provided for @bookingsCancelBooking.
  ///
  /// In es, this message translates to:
  /// **'ANULAR RESERVA'**
  String get bookingsCancelBooking;

  /// No description provided for @bookingsUpdateStatus.
  ///
  /// In es, this message translates to:
  /// **'Actualizar estado'**
  String get bookingsUpdateStatus;

  /// No description provided for @bookingActionUnavailableTitle.
  ///
  /// In es, this message translates to:
  /// **'Acción no disponible'**
  String get bookingActionUnavailableTitle;

  /// No description provided for @bookingCancelUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Solo se pueden anular reservas en estado reservada o confirmada.'**
  String get bookingCancelUnavailable;

  /// No description provided for @bookingConfirmUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Solo se pueden confirmar reservas en estado reservada o anulada.'**
  String get bookingConfirmUnavailable;

  /// No description provided for @bookingStatusUpdatedTitle.
  ///
  /// In es, this message translates to:
  /// **'Estado actualizado'**
  String get bookingStatusUpdatedTitle;

  /// No description provided for @bookingChangedToCanceled.
  ///
  /// In es, this message translates to:
  /// **'La reserva quedó anulada.'**
  String get bookingChangedToCanceled;

  /// No description provided for @bookingChangedToConfirmed.
  ///
  /// In es, this message translates to:
  /// **'La reserva quedó confirmada.'**
  String get bookingChangedToConfirmed;

  /// No description provided for @bookingUpdateFailedTitle.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar la reserva'**
  String get bookingUpdateFailedTitle;

  /// No description provided for @bookingUnexpectedErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado'**
  String get bookingUnexpectedErrorTitle;

  /// No description provided for @bookingUnexpectedErrorDetail.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar el estado de la reserva: {error}'**
  String bookingUnexpectedErrorDetail(String error);

  /// No description provided for @bookingCouldNotBookSession.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reservar la sesión'**
  String get bookingCouldNotBookSession;

  /// No description provided for @bookingCouldNotBookClassSlot.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reservar este horario'**
  String get bookingCouldNotBookClassSlot;

  /// No description provided for @bookingsLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar tus reservas'**
  String get bookingsLoadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
