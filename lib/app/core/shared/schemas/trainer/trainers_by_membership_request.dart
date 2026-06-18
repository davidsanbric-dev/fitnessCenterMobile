class TrainersByMembershipRequest {
  const TrainersByMembershipRequest({
    required this.membershipId,
    required this.disciplineCode,
  });

  final String membershipId;
  final int disciplineCode;

  Map<String, String> toQueryParameters() => {
    'disciplineCode': disciplineCode.toString(),
    'membershipId': membershipId.trim(),
  };
}
