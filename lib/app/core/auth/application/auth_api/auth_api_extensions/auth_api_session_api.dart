part of '../auth_api.dart';

extension AuthApiSessionApi on AuthApi {
  /// --- Session Methods ---
  Future<Map<String, dynamic>?> getCachedUser() {
    return _cache.getUser();
  }

  /// Firebase-only logout: sign out client-side and drop the local session.
  /// The backend exposes no logout endpoint under the Firebase-only model.
  Future<void> logout() async {
    await _cache.clearSession();
    await _safeSignOut();
  }

  Future<Map<String, dynamic>?> restoreSessionFromFirebase() async {
    final user = _firebaseAuthGateway.currentUser;
    if (user == null) {
      await _cache.clearSession();
      return null;
    }

    try {
      final session = await _cacheSessionForUserWithFallback(user);
      return session.claims;
    } catch (_) {
      await _cache.clearSession();
      return null;
    }
  }

  String _requireEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw const ApiException('Invalid email.');
    }
    return trimmed;
  }

  String _requirePassword(String password) {
    if (password.trim().isEmpty) {
      throw const ApiException('Password is required.');
    }
    return password;
  }

  User _requireUser() {
    final user = _firebaseAuthGateway.currentUser;
    if (user == null) {
      throw const ApiException('There is no active session.');
    }
    return user;
  }

  Future<SessionData> _cacheSessionForUser(User user) async {
    final idTokenResult = await user.getIdTokenResult(true);
    final token = (idTokenResult.token ?? '').trim();
    if (token.isEmpty) {
      throw const ApiException('No valid token was received.');
    }

    await _userApi.syncFirebaseClaims(token: token);

    final refreshedTokenResult = await user.getIdTokenResult(true);
    final refreshedToken = (refreshedTokenResult.token ?? '').trim();
    if (refreshedToken.isEmpty) {
      throw const ApiException('No valid token was received.');
    }

    final userDto = await _userApi.getUserByMail(
      mail: _requireEmail(user.email ?? ''),
      token: refreshedToken,
    );

    if (userDto == null) {
      throw const ApiException('User information was not found.');
    }

    final sessionClaims = _sessionClaimsMapper.fromUserDto(
      userDto: userDto,
      firebaseUser: user,
    );
    // Role and display name are no longer returned by /users/me under the
    // Firebase-only backend; they live in the custom claims the backend wrote
    // and that the force-refreshed token now carries (see spec §7).
    _applyCustomClaims(sessionClaims, refreshedTokenResult.claims);
    await _cache.saveSession(token: refreshedToken, user: sessionClaims);

    return SessionData(claims: sessionClaims, token: refreshedToken);
  }

  void _applyCustomClaims(
    Map<String, dynamic> sessionClaims,
    Map<String, dynamic>? tokenClaims,
  ) {
    if (tokenClaims == null) {
      return;
    }

    final role = tokenClaims['app_role'];
    if (role is String && role.trim().isNotEmpty) {
      final normalizedRole = role.trim();
      sessionClaims['roleName'] = normalizedRole;
      final roleObject = sessionClaims['role'];
      if (roleObject is Map) {
        roleObject['name'] = normalizedRole;
      }
    }

    final displayName = tokenClaims['app_display_name'];
    if (displayName is String && displayName.trim().isNotEmpty) {
      sessionClaims['userName'] = displayName.trim();
    }
  }

  Future<SessionData> _cacheSessionForUserWithFallback(User user) async {
    try {
      return await _cacheSessionForUser(user);
    } catch (_) {
      return _cacheFirebaseOnlySession(user);
    }
  }

  Future<SessionData> _cacheFirebaseOnlySession(User user) async {
    final idTokenResult = await user.getIdTokenResult(true);
    final token = (idTokenResult.token ?? '').trim();
    if (token.isEmpty) {
      throw const ApiException('No valid token was received.');
    }

    final claims = _sessionClaimsMapper.fromFirebaseUser(
      user,
      fallbackEmail: _requireEmail(user.email ?? ''),
    );

    await _cache.saveSession(token: token, user: claims);
    return SessionData(claims: claims, token: token);
  }

  Future<void> _safeSignOut() async {
    try {
      await _firebaseAuthGateway.signOut();
    } catch (_) {
      // Ignore Firebase sign out errors.
    }
  }
}
