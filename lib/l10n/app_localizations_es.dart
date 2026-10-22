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

  @override
  String get commonAction => 'Acción';

  @override
  String get dirAllDisciplines => 'Todas las disciplinas';

  @override
  String get slotAvailability => 'Disponibilidad';

  @override
  String get slotAvailableTimes => 'Horarios disponibles';

  @override
  String get bookingDetailsTitle => 'Detalle de la reserva';

  @override
  String get bookingOptionsTitle => 'Opciones de reserva';

  @override
  String get filterByClassType => 'Por tipo de clase';

  @override
  String get filterByDiscipline => 'Por disciplina';

  @override
  String get filterByDisciplineTrainer => 'Por disciplina o entrenador';

  @override
  String get filterByPlan => 'Por plan';

  @override
  String get filterByTrainer => 'Por entrenador';

  @override
  String get filterChange => 'Cambiar filtros';

  @override
  String get classOption => 'Opción de clase';

  @override
  String get classOptions => 'Opciones de clase';

  @override
  String get classType => 'Tipo de clase';

  @override
  String get classTypes => 'Tipos de clase';

  @override
  String get dirTrainerProfileFailed =>
      'No se pudo abrir el perfil del entrenador.';

  @override
  String get dirSelectDisciplineFailed =>
      'No se pudo seleccionar la disciplina.';

  @override
  String get dirSelectTrainerFailed => 'No se pudo seleccionar el entrenador.';

  @override
  String get commonCreatedAt => 'Creada el';

  @override
  String get commonDiscipline => 'Disciplina';

  @override
  String get commonDisciplines => 'Disciplinas';

  @override
  String get commonDuration => 'Duración';

  @override
  String get dirTitle => 'Directorio';

  @override
  String get commonGeneralInfo => 'Información general';

  @override
  String get commonGroup => 'Grupo';

  @override
  String get commonSchedule => 'Horario';

  @override
  String get filterHowToSearch => '¿Cómo quieres buscar?';

  @override
  String get commonMember => 'Socio';

  @override
  String get commonPlan => 'Plan';

  @override
  String get commonPlans => 'Planes';

  @override
  String get emptyNoAvailClassOption =>
      'No hay disponibilidad para esta opción de clase.';

  @override
  String get emptyNoAvailDiscipline =>
      'No hay disponibilidad para esta disciplina.';

  @override
  String get emptyNoAvailTrainer =>
      'No hay disponibilidad para este entrenador.';

  @override
  String get emptyNoSlotsForFilters =>
      'No hay horarios disponibles para los filtros seleccionados.';

  @override
  String get emptyNoBio => 'Este entrenador aún no tiene reseña.';

  @override
  String get emptyNoGroups => 'No hay grupos de clases disponibles por ahora.';

  @override
  String get emptyNoClassOptions =>
      'No hay opciones de clase para esta subcategoría.';

  @override
  String get emptyNoClassTypes =>
      'No hay tipos de clase para esta subcategoría.';

  @override
  String get emptyNoDisciplines => 'No hay disciplinas disponibles.';

  @override
  String get emptyNoPlans => 'No hay planes disponibles.';

  @override
  String get commonNoName => 'Sin nombre';

  @override
  String get emptyNoPreparation => 'No hay indicaciones de preparación.';

  @override
  String get commonNoStatus => 'Sin estado';

  @override
  String get emptyNoSubgroups =>
      'No hay subcategorías para el grupo seleccionado.';

  @override
  String get emptyNoTrainers => 'No hay entrenadores disponibles.';

  @override
  String get commonNormal => 'Normal';

  @override
  String get commonNotAvailable => 'No disponible';

  @override
  String get commonNotDefined => 'Sin definir';

  @override
  String get commonPhone => 'Teléfono';

  @override
  String get pickClassType => 'Elige un tipo de clase';

  @override
  String get commonPreparation => 'Preparación';

  @override
  String get commonInsurance => 'Previsión';

  @override
  String get commonScheduledAt => 'Agendada para';

  @override
  String get pickSubcategory => 'Elige una subcategoría';

  @override
  String get filterSelectValid =>
      'Selecciona opciones válidas antes de buscar.';

  @override
  String get commonServiceCentre => 'Servicio / Centro';

  @override
  String get commonSessionFeedback => 'Comentarios de la sesión';

  @override
  String get commonStatus => 'Estado';

  @override
  String get commonSubgroup => 'Subgrupo';

  @override
  String get commonBranch => 'Sucursal';

  @override
  String get commonTimeSlots => 'Horarios';

  @override
  String get commonTrainer => 'Entrenador';

  @override
  String get commonTrainerDiscipline => 'Entrenador / Disciplina';

  @override
  String get commonTrainerNotes => 'Notas del entrenador';

  @override
  String get commonTrainers => 'Entrenadores';

  @override
  String get viewPreparation => 'Ver preparación';

  @override
  String get filterWhatClass => '¿Qué tipo de clase buscas?';

  @override
  String get commonGroupPrefix => 'Grupo: ';

  @override
  String comingSoonDetail(String label) {
    return 'La información detallada de $label estará disponible pronto.';
  }

  @override
  String get searchDisciplineHint => 'Busca una disciplina';

  @override
  String get searchTrainerHint => 'Busca un entrenador';

  @override
  String get homeAssessmentsCard => 'Evaluaciones\nfísicas';

  @override
  String get homeTrainersCard => 'Conoce a los\nentrenadores';

  @override
  String get homeSubtitle => 'Reserva y gestiona tus clases desde donde estés';

  @override
  String get homeDiscover => 'Descubre todo lo que puedes hacer';

  @override
  String get homeTrainSmarter => 'Entrena mejor, sin complicaciones';

  @override
  String get homeStartToday => 'Empieza hoy';

  @override
  String get homeLearnMore => 'Saber más';

  @override
  String get homeReadMore => 'Leer más';

  @override
  String get homeViewAll => 'Ver todo';

  @override
  String get homeBookingToday => 'Reserva para hoy';

  @override
  String get homeLoadingNext => 'Cargando tu próxima reserva...';

  @override
  String get homeLoadingHistory => 'Cargando tu historial de entrenamiento...';

  @override
  String get homeHistoryLoadFailed =>
      'No pudimos cargar tu historial de entrenamiento.';

  @override
  String get homeHistoryEmpty => 'Tus sesiones completadas aparecerán aquí.';

  @override
  String get commonSession => 'Sesión';

  @override
  String planPrice(String amount) {
    return 'Precio: \$$amount';
  }

  @override
  String planUpToSessions(int count) {
    return 'Hasta $count sesiones / mes';
  }

  @override
  String planUpToSession(int count) {
    return 'Hasta $count sesión / mes';
  }

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String get profilePersonalInfo => 'Información personal';

  @override
  String get profileFullName => 'Nombre completo';

  @override
  String get profileMembershipPlan => 'Plan de membresía';

  @override
  String get profileTrainingHistory => 'Historial de entrenamiento';

  @override
  String get profileAssessmentResults => 'Resultados de evaluación';

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String get profileDetails => 'Detalles';

  @override
  String get profileNoAssessments => 'Aún no hay notas de evaluación.';

  @override
  String get profileNoSessions => 'Aún no tienes sesiones completadas.';

  @override
  String get profileTrainerFeedback => 'Comentarios del entrenador';

  @override
  String get profilePhotoUpdated => 'Foto de perfil actualizada.';

  @override
  String profileSignOutFailed(String error) {
    return 'No se pudo cerrar sesión: $error';
  }

  @override
  String profilePhotoFailed(String error) {
    return 'No se pudo actualizar la foto: $error';
  }

  @override
  String get commonDetailsLoadFailed => 'No se pudieron cargar los detalles';

  @override
  String get commonUnexpectedError => 'Error inesperado';

  @override
  String homeLastSession(String session, String trainer, String date) {
    return 'Última: $session$trainer, $date.';
  }

  @override
  String homeTodaySession(String session, String trainer, String time) {
    return 'Hoy: $session$trainer, $time.';
  }

  @override
  String homeNextSession(
    String session,
    String trainer,
    String date,
    String time,
  ) {
    return 'Próxima: $session$trainer, $date a las $time.';
  }

  @override
  String commonWithTrainer(String trainer) {
    return ' con $trainer';
  }

  @override
  String get assessmentEmpty =>
      'Los comentarios de tu entrenador aparecerán aquí después de una sesión completada.';

  @override
  String get commonTime => 'Hora';

  @override
  String get commonBook => 'Reservar';

  @override
  String bookingConfirmed(String capability, String when) {
    return '$capability reservada para $when.';
  }

  @override
  String get bookingClassSlotFailed => 'No se pudo reservar este horario.';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCreate => 'Crear';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonAssign => 'Asignar';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonError => 'Error';

  @override
  String get commonRange => 'Rango';

  @override
  String get deleteItemTitle => 'Eliminar elemento';

  @override
  String get deleteItemPrompt => '¿Quieres eliminar este elemento?';

  @override
  String get itemDeleted => 'Elemento eliminado.';

  @override
  String get validationRequired => 'Este campo es obligatorio';

  @override
  String get validationEmail => 'Ingresa un correo válido';

  @override
  String get validationMinLength => 'No se alcanza la longitud mínima';

  @override
  String get selectDateRange => 'Selecciona un rango de fechas';

  @override
  String get filtersAdvanced => 'Filtros\\navanzados';

  @override
  String get filtersAdvancedActive => 'Filtros avanzados\\n(activos)';

  @override
  String get filtersAdvancedActiveLabel => 'Filtros avanzados activos';

  @override
  String get filtersAdvancedOpen => 'Abrir filtros avanzados';

  @override
  String get emptyNoMatches => 'No hay coincidencias.';

  @override
  String get emptyNoOptions => 'No hay opciones disponibles.';

  @override
  String get emptyNoOptionsNow => 'No hay opciones disponibles por el momento.';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusConfirmed => 'Confirmada';

  @override
  String get statusCancelled => 'Anulada';

  @override
  String get statusCompleted => 'Completada';
}
