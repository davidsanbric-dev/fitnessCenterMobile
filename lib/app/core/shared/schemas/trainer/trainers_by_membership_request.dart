class TrainersByMembershipRequest {
  const TrainersByMembershipRequest({
    required this.membershipId,
    required this.locationCode,
    required this.disciplineCode,
  });

  final String membershipId;
  final int locationCode;
  final int disciplineCode;

  Map<String, String> toQueryParameters() => {
    'locationCode': locationCode.toString(),
    'disciplineCode': disciplineCode.toString(),
    'membershipId': membershipId.trim(),
  };
}
