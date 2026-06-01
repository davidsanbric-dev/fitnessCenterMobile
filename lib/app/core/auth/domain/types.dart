class SessionData {
  const SessionData({required this.claims, required this.token});

  final Map<String, dynamic> claims;
  final String token;
}
