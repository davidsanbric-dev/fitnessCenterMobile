/// Payload for scheduling a by-trainer booking. The wire body is assembled in
/// `BookingAgendaApi.scheduleBooking` (snake_case: booking_date, booking_time,
/// location_code, session_duration_minutes, discipline_code, trainer_code,
/// notes); this holds the raw values and trims them for that mapping.
class ScheduleBookingRequest {
  const ScheduleBookingRequest({
    required this.date,
    required this.time,
    required this.locationCode,
    required this.bookingDuration,
    required this.disciplineCode,
    required this.trainerCode,
    this.observation = '',
  });

  final String date;
  final String time;
  final String locationCode;
  final int bookingDuration;
  final int disciplineCode;
  final int trainerCode;
  final String observation;

  String get trimmedDate => date.trim();
  String get trimmedTime => time.trim();
  String get trimmedLocationCode => locationCode.trim();
  String get trimmedObservation => observation.trim();
}
