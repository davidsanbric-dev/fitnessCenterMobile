class MemberRequest {
  const MemberRequest({required this.memberId});

  final String memberId;

  Map<String, String> toQueryParameters() => {'memberId': memberId.trim()};
}
