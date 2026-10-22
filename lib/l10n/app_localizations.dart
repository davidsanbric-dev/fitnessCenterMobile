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

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navBookings.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get navBookings;

  /// No description provided for @navDirectory.
  ///
  /// In es, this message translates to:
  /// **'Directorio'**
  String get navDirectory;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @navSlots.
  ///
  /// In es, this message translates to:
  /// **'Horarios'**
  String get navSlots;

  /// No description provided for @brandSlogan.
  ///
  /// In es, this message translates to:
  /// **'ahora aún más cerca de ti'**
  String get brandSlogan;

  /// No description provided for @homeGreeting.
  ///
  /// In es, this message translates to:
  /// **'¡Hola, {name}!'**
  String homeGreeting(String name);

  /// No description provided for @homeGreetingNoName.
  ///
  /// In es, this message translates to:
  /// **'¡Hola!'**
  String get homeGreetingNoName;

  /// No description provided for @homeExploreDisciplines.
  ///
  /// In es, this message translates to:
  /// **'Explorar\ndisciplinas'**
  String get homeExploreDisciplines;

  /// No description provided for @homeUpcomingBookings.
  ///
  /// In es, this message translates to:
  /// **'Próximas reservas'**
  String get homeUpcomingBookings;

  /// No description provided for @homeHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get homeHistory;

  /// No description provided for @homeViewHistory.
  ///
  /// In es, this message translates to:
  /// **'Ver historial'**
  String get homeViewHistory;

  /// No description provided for @homeViewBookings.
  ///
  /// In es, this message translates to:
  /// **'Ver reservas'**
  String get homeViewBookings;

  /// No description provided for @homeNoUpcoming.
  ///
  /// In es, this message translates to:
  /// **'No tienes reservas próximas en FitnessCenter.'**
  String get homeNoUpcoming;

  /// No description provided for @homeUpcomingLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus próximas reservas.'**
  String get homeUpcomingLoadFailed;

  /// No description provided for @commonClass.
  ///
  /// In es, this message translates to:
  /// **'Clase'**
  String get commonClass;

  /// No description provided for @paginationPrevious.
  ///
  /// In es, this message translates to:
  /// **'Página anterior'**
  String get paginationPrevious;

  /// No description provided for @paginationNext.
  ///
  /// In es, this message translates to:
  /// **'Página siguiente'**
  String get paginationNext;

  /// No description provided for @paginationZeroResults.
  ///
  /// In es, this message translates to:
  /// **'0 resultados'**
  String get paginationZeroResults;

  /// No description provided for @paginationPage.
  ///
  /// In es, this message translates to:
  /// **'Página {page}'**
  String paginationPage(int page);

  /// No description provided for @paginationPageOf.
  ///
  /// In es, this message translates to:
  /// **'Página {page} de {total}'**
  String paginationPageOf(int page, int total);

  /// No description provided for @paginationShowing.
  ///
  /// In es, this message translates to:
  /// **'Mostrando {start}-{end} de {total}'**
  String paginationShowing(int start, int end, int total);

  /// No description provided for @commonAction.
  ///
  /// In es, this message translates to:
  /// **'Acción'**
  String get commonAction;

  /// No description provided for @dirAllDisciplines.
  ///
  /// In es, this message translates to:
  /// **'Todas las disciplinas'**
  String get dirAllDisciplines;

  /// No description provided for @slotAvailability.
  ///
  /// In es, this message translates to:
  /// **'Disponibilidad'**
  String get slotAvailability;

  /// No description provided for @slotAvailableTimes.
  ///
  /// In es, this message translates to:
  /// **'Horarios disponibles'**
  String get slotAvailableTimes;

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de la reserva'**
  String get bookingDetailsTitle;

  /// No description provided for @bookingOptionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Opciones de reserva'**
  String get bookingOptionsTitle;

  /// No description provided for @filterByClassType.
  ///
  /// In es, this message translates to:
  /// **'Por tipo de clase'**
  String get filterByClassType;

  /// No description provided for @filterByDiscipline.
  ///
  /// In es, this message translates to:
  /// **'Por disciplina'**
  String get filterByDiscipline;

  /// No description provided for @filterByDisciplineTrainer.
  ///
  /// In es, this message translates to:
  /// **'Por disciplina o entrenador'**
  String get filterByDisciplineTrainer;

  /// No description provided for @filterByPlan.
  ///
  /// In es, this message translates to:
  /// **'Por plan'**
  String get filterByPlan;

  /// No description provided for @filterByTrainer.
  ///
  /// In es, this message translates to:
  /// **'Por entrenador'**
  String get filterByTrainer;

  /// No description provided for @filterChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar filtros'**
  String get filterChange;

  /// No description provided for @classOption.
  ///
  /// In es, this message translates to:
  /// **'Opción de clase'**
  String get classOption;

  /// No description provided for @classOptions.
  ///
  /// In es, this message translates to:
  /// **'Opciones de clase'**
  String get classOptions;

  /// No description provided for @classType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de clase'**
  String get classType;

  /// No description provided for @classTypes.
  ///
  /// In es, this message translates to:
  /// **'Tipos de clase'**
  String get classTypes;

  /// No description provided for @dirTrainerProfileFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el perfil del entrenador.'**
  String get dirTrainerProfileFailed;

  /// No description provided for @dirSelectDisciplineFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo seleccionar la disciplina.'**
  String get dirSelectDisciplineFailed;

  /// No description provided for @dirSelectTrainerFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo seleccionar el entrenador.'**
  String get dirSelectTrainerFailed;

  /// No description provided for @commonCreatedAt.
  ///
  /// In es, this message translates to:
  /// **'Creada el'**
  String get commonCreatedAt;

  /// No description provided for @commonDiscipline.
  ///
  /// In es, this message translates to:
  /// **'Disciplina'**
  String get commonDiscipline;

  /// No description provided for @commonDisciplines.
  ///
  /// In es, this message translates to:
  /// **'Disciplinas'**
  String get commonDisciplines;

  /// No description provided for @commonDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get commonDuration;

  /// No description provided for @dirTitle.
  ///
  /// In es, this message translates to:
  /// **'Directorio'**
  String get dirTitle;

  /// No description provided for @commonGeneralInfo.
  ///
  /// In es, this message translates to:
  /// **'Información general'**
  String get commonGeneralInfo;

  /// No description provided for @commonGroup.
  ///
  /// In es, this message translates to:
  /// **'Grupo'**
  String get commonGroup;

  /// No description provided for @commonSchedule.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get commonSchedule;

  /// No description provided for @filterHowToSearch.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo quieres buscar?'**
  String get filterHowToSearch;

  /// No description provided for @commonMember.
  ///
  /// In es, this message translates to:
  /// **'Socio'**
  String get commonMember;

  /// No description provided for @commonPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get commonPlan;

  /// No description provided for @commonPlans.
  ///
  /// In es, this message translates to:
  /// **'Planes'**
  String get commonPlans;

  /// No description provided for @emptyNoAvailClassOption.
  ///
  /// In es, this message translates to:
  /// **'No hay disponibilidad para esta opción de clase.'**
  String get emptyNoAvailClassOption;

  /// No description provided for @emptyNoAvailDiscipline.
  ///
  /// In es, this message translates to:
  /// **'No hay disponibilidad para esta disciplina.'**
  String get emptyNoAvailDiscipline;

  /// No description provided for @emptyNoAvailTrainer.
  ///
  /// In es, this message translates to:
  /// **'No hay disponibilidad para este entrenador.'**
  String get emptyNoAvailTrainer;

  /// No description provided for @emptyNoSlotsForFilters.
  ///
  /// In es, this message translates to:
  /// **'No hay horarios disponibles para los filtros seleccionados.'**
  String get emptyNoSlotsForFilters;

  /// No description provided for @emptyNoBio.
  ///
  /// In es, this message translates to:
  /// **'Este entrenador aún no tiene reseña.'**
  String get emptyNoBio;

  /// No description provided for @emptyNoGroups.
  ///
  /// In es, this message translates to:
  /// **'No hay grupos de clases disponibles por ahora.'**
  String get emptyNoGroups;

  /// No description provided for @emptyNoClassOptions.
  ///
  /// In es, this message translates to:
  /// **'No hay opciones de clase para esta subcategoría.'**
  String get emptyNoClassOptions;

  /// No description provided for @emptyNoClassTypes.
  ///
  /// In es, this message translates to:
  /// **'No hay tipos de clase para esta subcategoría.'**
  String get emptyNoClassTypes;

  /// No description provided for @emptyNoDisciplines.
  ///
  /// In es, this message translates to:
  /// **'No hay disciplinas disponibles.'**
  String get emptyNoDisciplines;

  /// No description provided for @emptyNoPlans.
  ///
  /// In es, this message translates to:
  /// **'No hay planes disponibles.'**
  String get emptyNoPlans;

  /// No description provided for @commonNoName.
  ///
  /// In es, this message translates to:
  /// **'Sin nombre'**
  String get commonNoName;

  /// No description provided for @emptyNoPreparation.
  ///
  /// In es, this message translates to:
  /// **'No hay indicaciones de preparación.'**
  String get emptyNoPreparation;

  /// No description provided for @commonNoStatus.
  ///
  /// In es, this message translates to:
  /// **'Sin estado'**
  String get commonNoStatus;

  /// No description provided for @emptyNoSubgroups.
  ///
  /// In es, this message translates to:
  /// **'No hay subcategorías para el grupo seleccionado.'**
  String get emptyNoSubgroups;

  /// No description provided for @emptyNoTrainers.
  ///
  /// In es, this message translates to:
  /// **'No hay entrenadores disponibles.'**
  String get emptyNoTrainers;

  /// No description provided for @commonNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get commonNormal;

  /// No description provided for @commonNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get commonNotAvailable;

  /// No description provided for @commonNotDefined.
  ///
  /// In es, this message translates to:
  /// **'Sin definir'**
  String get commonNotDefined;

  /// No description provided for @commonPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get commonPhone;

  /// No description provided for @pickClassType.
  ///
  /// In es, this message translates to:
  /// **'Elige un tipo de clase'**
  String get pickClassType;

  /// No description provided for @commonPreparation.
  ///
  /// In es, this message translates to:
  /// **'Preparación'**
  String get commonPreparation;

  /// No description provided for @commonInsurance.
  ///
  /// In es, this message translates to:
  /// **'Previsión'**
  String get commonInsurance;

  /// No description provided for @commonScheduledAt.
  ///
  /// In es, this message translates to:
  /// **'Agendada para'**
  String get commonScheduledAt;

  /// No description provided for @pickSubcategory.
  ///
  /// In es, this message translates to:
  /// **'Elige una subcategoría'**
  String get pickSubcategory;

  /// No description provided for @filterSelectValid.
  ///
  /// In es, this message translates to:
  /// **'Selecciona opciones válidas antes de buscar.'**
  String get filterSelectValid;

  /// No description provided for @commonServiceCentre.
  ///
  /// In es, this message translates to:
  /// **'Servicio / Centro'**
  String get commonServiceCentre;

  /// No description provided for @commonSessionFeedback.
  ///
  /// In es, this message translates to:
  /// **'Comentarios de la sesión'**
  String get commonSessionFeedback;

  /// No description provided for @commonStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get commonStatus;

  /// No description provided for @commonSubgroup.
  ///
  /// In es, this message translates to:
  /// **'Subgrupo'**
  String get commonSubgroup;

  /// No description provided for @commonBranch.
  ///
  /// In es, this message translates to:
  /// **'Sucursal'**
  String get commonBranch;

  /// No description provided for @commonTimeSlots.
  ///
  /// In es, this message translates to:
  /// **'Horarios'**
  String get commonTimeSlots;

  /// No description provided for @commonTrainer.
  ///
  /// In es, this message translates to:
  /// **'Entrenador'**
  String get commonTrainer;

  /// No description provided for @commonTrainerDiscipline.
  ///
  /// In es, this message translates to:
  /// **'Entrenador / Disciplina'**
  String get commonTrainerDiscipline;

  /// No description provided for @commonTrainerNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas del entrenador'**
  String get commonTrainerNotes;

  /// No description provided for @commonTrainers.
  ///
  /// In es, this message translates to:
  /// **'Entrenadores'**
  String get commonTrainers;

  /// No description provided for @viewPreparation.
  ///
  /// In es, this message translates to:
  /// **'Ver preparación'**
  String get viewPreparation;

  /// No description provided for @filterWhatClass.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tipo de clase buscas?'**
  String get filterWhatClass;

  /// No description provided for @commonGroupPrefix.
  ///
  /// In es, this message translates to:
  /// **'Grupo: '**
  String get commonGroupPrefix;

  /// No description provided for @comingSoonDetail.
  ///
  /// In es, this message translates to:
  /// **'La información detallada de {label} estará disponible pronto.'**
  String comingSoonDetail(String label);

  /// No description provided for @searchDisciplineHint.
  ///
  /// In es, this message translates to:
  /// **'Busca una disciplina'**
  String get searchDisciplineHint;

  /// No description provided for @searchTrainerHint.
  ///
  /// In es, this message translates to:
  /// **'Busca un entrenador'**
  String get searchTrainerHint;

  /// No description provided for @homeAssessmentsCard.
  ///
  /// In es, this message translates to:
  /// **'Evaluaciones\nfísicas'**
  String get homeAssessmentsCard;

  /// No description provided for @homeTrainersCard.
  ///
  /// In es, this message translates to:
  /// **'Conoce a los\nentrenadores'**
  String get homeTrainersCard;

  /// No description provided for @homeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reserva y gestiona tus clases desde donde estés'**
  String get homeSubtitle;

  /// No description provided for @homeDiscover.
  ///
  /// In es, this message translates to:
  /// **'Descubre todo lo que puedes hacer'**
  String get homeDiscover;

  /// No description provided for @homeTrainSmarter.
  ///
  /// In es, this message translates to:
  /// **'Entrena mejor, sin complicaciones'**
  String get homeTrainSmarter;

  /// No description provided for @homeStartToday.
  ///
  /// In es, this message translates to:
  /// **'Empieza hoy'**
  String get homeStartToday;

  /// No description provided for @homeLearnMore.
  ///
  /// In es, this message translates to:
  /// **'Saber más'**
  String get homeLearnMore;

  /// No description provided for @homeReadMore.
  ///
  /// In es, this message translates to:
  /// **'Leer más'**
  String get homeReadMore;

  /// No description provided for @homeViewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get homeViewAll;

  /// No description provided for @homeBookingToday.
  ///
  /// In es, this message translates to:
  /// **'Reserva para hoy'**
  String get homeBookingToday;

  /// No description provided for @homeLoadingNext.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu próxima reserva...'**
  String get homeLoadingNext;

  /// No description provided for @homeLoadingHistory.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu historial de entrenamiento...'**
  String get homeLoadingHistory;

  /// No description provided for @homeHistoryLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu historial de entrenamiento.'**
  String get homeHistoryLoadFailed;

  /// No description provided for @homeHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Tus sesiones completadas aparecerán aquí.'**
  String get homeHistoryEmpty;

  /// No description provided for @commonSession.
  ///
  /// In es, this message translates to:
  /// **'Sesión'**
  String get commonSession;

  /// No description provided for @planPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio: \${amount}'**
  String planPrice(String amount);

  /// No description provided for @planUpToSessions.
  ///
  /// In es, this message translates to:
  /// **'Hasta {count} sesiones / mes'**
  String planUpToSessions(int count);

  /// No description provided for @planUpToSession.
  ///
  /// In es, this message translates to:
  /// **'Hasta {count} sesión / mes'**
  String planUpToSession(int count);

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get profileTitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In es, this message translates to:
  /// **'Información personal'**
  String get profilePersonalInfo;

  /// No description provided for @profileFullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get profileFullName;

  /// No description provided for @profileMembershipPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan de membresía'**
  String get profileMembershipPlan;

  /// No description provided for @profileTrainingHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de entrenamiento'**
  String get profileTrainingHistory;

  /// No description provided for @profileAssessmentResults.
  ///
  /// In es, this message translates to:
  /// **'Resultados de evaluación'**
  String get profileAssessmentResults;

  /// No description provided for @profileSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileSignOut;

  /// No description provided for @profileDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get profileDetails;

  /// No description provided for @profileNoAssessments.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay notas de evaluación.'**
  String get profileNoAssessments;

  /// No description provided for @profileNoSessions.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes sesiones completadas.'**
  String get profileNoSessions;

  /// No description provided for @profileTrainerFeedback.
  ///
  /// In es, this message translates to:
  /// **'Comentarios del entrenador'**
  String get profileTrainerFeedback;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil actualizada.'**
  String get profilePhotoUpdated;

  /// No description provided for @profileSignOutFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cerrar sesión: {error}'**
  String profileSignOutFailed(String error);

  /// No description provided for @profilePhotoFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar la foto: {error}'**
  String profilePhotoFailed(String error);

  /// No description provided for @commonDetailsLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los detalles'**
  String get commonDetailsLoadFailed;

  /// No description provided for @commonUnexpectedError.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado'**
  String get commonUnexpectedError;

  /// No description provided for @homeLastSession.
  ///
  /// In es, this message translates to:
  /// **'Última: {session}{trainer}, {date}.'**
  String homeLastSession(String session, String trainer, String date);

  /// No description provided for @homeTodaySession.
  ///
  /// In es, this message translates to:
  /// **'Hoy: {session}{trainer}, {time}.'**
  String homeTodaySession(String session, String trainer, String time);

  /// No description provided for @homeNextSession.
  ///
  /// In es, this message translates to:
  /// **'Próxima: {session}{trainer}, {date} a las {time}.'**
  String homeNextSession(
    String session,
    String trainer,
    String date,
    String time,
  );

  /// No description provided for @commonWithTrainer.
  ///
  /// In es, this message translates to:
  /// **' con {trainer}'**
  String commonWithTrainer(String trainer);

  /// No description provided for @assessmentEmpty.
  ///
  /// In es, this message translates to:
  /// **'Los comentarios de tu entrenador aparecerán aquí después de una sesión completada.'**
  String get assessmentEmpty;

  /// No description provided for @commonTime.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get commonTime;

  /// No description provided for @commonBook.
  ///
  /// In es, this message translates to:
  /// **'Reservar'**
  String get commonBook;

  /// No description provided for @bookingConfirmed.
  ///
  /// In es, this message translates to:
  /// **'{capability} reservada para {when}.'**
  String bookingConfirmed(String capability, String when);

  /// No description provided for @bookingClassSlotFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reservar este horario.'**
  String get bookingClassSlotFailed;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get commonCreate;

  /// No description provided for @commonEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonAssign.
  ///
  /// In es, this message translates to:
  /// **'Asignar'**
  String get commonAssign;

  /// No description provided for @commonSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get commonSearch;

  /// No description provided for @commonError.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonRange.
  ///
  /// In es, this message translates to:
  /// **'Rango'**
  String get commonRange;

  /// No description provided for @deleteItemTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar elemento'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres eliminar este elemento?'**
  String get deleteItemPrompt;

  /// No description provided for @itemDeleted.
  ///
  /// In es, this message translates to:
  /// **'Elemento eliminado.'**
  String get itemDeleted;

  /// No description provided for @validationRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido'**
  String get validationEmail;

  /// No description provided for @validationMinLength.
  ///
  /// In es, this message translates to:
  /// **'No se alcanza la longitud mínima'**
  String get validationMinLength;

  /// No description provided for @selectDateRange.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un rango de fechas'**
  String get selectDateRange;

  /// No description provided for @filtersAdvanced.
  ///
  /// In es, this message translates to:
  /// **'Filtros\\navanzados'**
  String get filtersAdvanced;

  /// No description provided for @filtersAdvancedActive.
  ///
  /// In es, this message translates to:
  /// **'Filtros avanzados\\n(activos)'**
  String get filtersAdvancedActive;

  /// No description provided for @filtersAdvancedActiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Filtros avanzados activos'**
  String get filtersAdvancedActiveLabel;

  /// No description provided for @filtersAdvancedOpen.
  ///
  /// In es, this message translates to:
  /// **'Abrir filtros avanzados'**
  String get filtersAdvancedOpen;

  /// No description provided for @emptyNoMatches.
  ///
  /// In es, this message translates to:
  /// **'No hay coincidencias.'**
  String get emptyNoMatches;

  /// No description provided for @emptyNoOptions.
  ///
  /// In es, this message translates to:
  /// **'No hay opciones disponibles.'**
  String get emptyNoOptions;

  /// No description provided for @emptyNoOptionsNow.
  ///
  /// In es, this message translates to:
  /// **'No hay opciones disponibles por el momento.'**
  String get emptyNoOptionsNow;

  /// No description provided for @statusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get statusConfirmed;

  /// No description provided for @statusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Anulada'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get statusCompleted;
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
