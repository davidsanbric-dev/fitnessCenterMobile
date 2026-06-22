// Centralized auth request/response schema
// Small immutable data class for authentication payloads
import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';

class AuthRequest {
  final String mail;
  final String password;

  const AuthRequest({required this.mail, required this.password});

  factory AuthRequest.fromJson(Map<String, dynamic> json) => AuthRequest(
    mail: normReqString(json['mail']),
    password: normReqString(json['password']),
  );

  Map<String, dynamic> toJson() => {'mail': mail, 'password': password};

  AuthRequest copyWith({String? mail, String? password}) {
    return AuthRequest(
      mail: mail ?? this.mail,
      password: password ?? this.password,
    );
  }
}

// Optionally a response class could be added here if needed.
