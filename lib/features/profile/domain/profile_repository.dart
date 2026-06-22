/// The auth-session data the Personal Information sub-page prefills its
/// read-only fields from: the cached claims and an on-demand session refresh.
abstract interface class ProfileRepository {
  Future<Map<String, dynamic>?> getCachedUser();

  bool get hasFirebaseSession;

  Future<Map<String, dynamic>?> restoreSessionFromFirebase();
}
