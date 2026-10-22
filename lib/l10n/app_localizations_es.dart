// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonClear => 'Limpiar';

  @override
  String get commonMenu => 'Menú';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonRowActions => 'Acciones de la fila';

  @override
  String get commonNoRecords => 'No hay registros disponibles.';

  @override
  String get commonNotSpecified => 'Sin especificar';

  @override
  String get commonViewProfile => 'Ver perfil';

  @override
  String get authAccessAccount => 'Accede a tu cuenta';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authEmailHint => 'Ingresa tu correo';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authPasswordHint => 'Ingresa tu contraseña';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authResendVerification => 'Reenviar correo de verificación';

  @override
  String get authIHaveVerified => 'Ya verifiqué';

  @override
  String get authWelcomeTitle => '¡Bienvenido!';

  @override
  String get authWelcomeSubtitle => 'Ingresa tu correo para continuar';

  @override
  String get bookingsTitle => 'Mis reservas';

  @override
  String get bookingsBookSession => 'Reservar una clase';

  @override
  String get bookingsEmpty => 'Aún no tienes reservas.';

  @override
  String get bookingsColumnTime => 'Horario';

  @override
  String get bookingsColumnClassTrainer => 'Clase / Entrenador';

  @override
  String get bookingsColumnActions => 'Acciones';

  @override
  String get bookingsTrainerPending => 'Entrenador por asignar';

  @override
  String get bookingsViewDetails => 'Ver detalles';

  @override
  String get bookingsConfirmBooking => 'CONFIRMAR RESERVA';

  @override
  String get bookingsCancelBooking => 'ANULAR RESERVA';

  @override
  String get bookingsUpdateStatus => 'Actualizar estado';

  @override
  String get bookingActionUnavailableTitle => 'Acción no disponible';

  @override
  String get bookingCancelUnavailable =>
      'Solo se pueden anular reservas en estado reservada o confirmada.';

  @override
  String get bookingConfirmUnavailable =>
      'Solo se pueden confirmar reservas en estado reservada o anulada.';

  @override
  String get bookingStatusUpdatedTitle => 'Estado actualizado';

  @override
  String get bookingChangedToCanceled => 'La reserva quedó anulada.';

  @override
  String get bookingChangedToConfirmed => 'La reserva quedó confirmada.';

  @override
  String get bookingUpdateFailedTitle => 'No se pudo actualizar la reserva';

  @override
  String get bookingUnexpectedErrorTitle => 'Error inesperado';

  @override
  String bookingUnexpectedErrorDetail(String error) {
    return 'No se pudo actualizar el estado de la reserva: $error';
  }

  @override
  String get bookingCouldNotBookSession => 'No se pudo reservar la sesión';

  @override
  String get bookingCouldNotBookClassSlot => 'No se pudo reservar este horario';

  @override
  String get bookingsLoadFailed => 'No se pudieron cargar tus reservas';

  @override
  String get navHome => 'Inicio';

  @override
  String get navBookings => 'Reservas';

  @override
  String get navDirectory => 'Directorio';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSlots => 'Horarios';

  @override
  String get brandSlogan => 'ahora aún más cerca de ti';

  @override
  String homeGreeting(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get homeGreetingNoName => '¡Hola!';

  @override
  String get homeExploreDisciplines => 'Explorar\ndisciplinas';

  @override
  String get homeUpcomingBookings => 'Próximas reservas';

  @override
  String get homeHistory => 'Historial';

  @override
  String get homeViewHistory => 'Ver historial';

  @override
  String get homeViewBookings => 'Ver reservas';

  @override
  String get homeNoUpcoming => 'No tienes reservas próximas en FitnessCenter.';

  @override
  String get homeUpcomingLoadFailed =>
      'No pudimos cargar tus próximas reservas.';

  @override
  String get commonClass => 'Clase';

  @override
  String get paginationPrevious => 'Página anterior';

  @override
  String get paginationNext => 'Página siguiente';

  @override
  String get paginationZeroResults => '0 resultados';

  @override
  String paginationPage(int page) {
    return 'Página $page';
  }

  @override
  String paginationPageOf(int page, int total) {
    return 'Página $page de $total';
  }

  @override
  String paginationShowing(int start, int end, int total) {
    return 'Mostrando $start-$end de $total';
  }
}
