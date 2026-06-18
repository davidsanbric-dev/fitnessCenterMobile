class AvailableSlotsByCapabilityRequest {
  const AvailableSlotsByCapabilityRequest({
    required this.capabilityId,
    this.queryType = 3,
    this.startDate,
    this.endDate,
    this.trainerCode,
    this.capabilityDescription,
  });

  final int capabilityId;
  final int queryType;
  final String? startDate;
  final String? endDate;
  final String? trainerCode;
  final String? capabilityDescription;

  // Update later to remove hardcoded date range values
  //(Including UI date-range picker)
  Map<String, String> toQueryParameters({int windowDays = 14}) {
    final defaultStartDate = DateTime.now();
    final normalizedStartDate = startDate?.trim() ?? '';
    final normalizedEndDate = endDate?.trim() ?? '';
    final normalizedTrainer = trainerCode?.trim() ?? '';
    final resolvedStartDate = normalizedStartDate.isEmpty
        ? defaultStartDate
        : DateTime.tryParse(normalizedStartDate) ?? defaultStartDate;
    final resolvedEndDate = normalizedEndDate.isEmpty
        ? resolvedStartDate.add(Duration(days: windowDays))
        : DateTime.tryParse(normalizedEndDate) ??
              resolvedStartDate.add(Duration(days: windowDays));

    return {
      'queryType': queryType.toString(),
      'capabilityId': capabilityId.toString(),
      'startDate': resolvedStartDate.toIso8601String(),
      'endDate': resolvedEndDate.toIso8601String(),
      if (normalizedTrainer.isNotEmpty) 'trainerCode': normalizedTrainer,
    };
  }

  AvailableSlotsByCapabilityRequest copyWith({
    int? capabilityId,
    int? queryType,
    String? startDate,
    String? endDate,
    String? trainerCode,
    String? capabilityDescription,
  }) {
    return AvailableSlotsByCapabilityRequest(
      capabilityId: capabilityId ?? this.capabilityId,
      queryType: queryType ?? this.queryType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      trainerCode: trainerCode ?? this.trainerCode,
      capabilityDescription:
          capabilityDescription ?? this.capabilityDescription,
    );
  }
}
