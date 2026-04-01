class ScheduleBookingByClassTypeRequest {
  const ScheduleBookingByClassTypeRequest({
    required this.bookingDate,
    required this.bookingTime,
    required this.locationCode,
    required this.trainerCode,
    required this.slotAssignmentCode,
    required this.classTypeId,
    this.notes,
  });

  final String bookingDate;
  final String bookingTime;
  final String locationCode;
  final int trainerCode;
  final String slotAssignmentCode;
  final int classTypeId;
  final String? notes;
}
