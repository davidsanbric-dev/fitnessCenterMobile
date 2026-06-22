import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/profile/domain/domain.dart';

/// Drives the Personal Information sub-page: prefills the read-only member
/// fields from the cached / refreshed auth-session claims.
class ProfileViewModel extends ViewModelBase {
  ProfileViewModel({ProfileRepository? repository})
    : _repository = repository ?? (throw ArgumentError.notNull('repository'));

  final ProfileRepository _repository;

  String? fullName;
  String? email;
  String? phone;
  String? rut;
  String? selectedMembership;

  /// Loads the cached claims, prefills the member fields, and — only when the
  /// cached payload is structurally incomplete (no `details` map) — forces one
  /// session refresh.
  Future<void> start() async {
    var cachedUser = await _repository.getCachedUser();
    if ((cachedUser == null || cachedUser.isEmpty) &&
        _repository.hasFirebaseSession) {
      cachedUser = await _repository.restoreSessionFromFirebase();
    }
    if (cachedUser == null || cachedUser.isEmpty) {
      return;
    }

    // Paint the fields from the cached claims right away. Name/email/phone/rut
    // are already present locally, so the user sees them without waiting on the
    // (multi-round-trip) Firebase session refresh below.
    _applyClaims(cachedUser);

    // A missing membership claim is not a reason to refresh: the session
    // pipeline never writes one, so refreshing for it would pay the network
    // cost on every visit without ever resolving it.
    final details = _claimMap(cachedUser, ['details', 'Details']);
    if (details.isEmpty && _repository.hasFirebaseSession) {
      final refreshedClaims = await _repository.restoreSessionFromFirebase();
      if (refreshedClaims != null && refreshedClaims.isNotEmpty) {
        _applyClaims(refreshedClaims);
      }
    }
  }

  void _applyClaims(Map<String, dynamic> claims) {
    final details = _claimMap(claims, ['details', 'Details']);
    final membershipFromClaims =
        _claimValue(details, ['membership']) ??
        _claimValue(claims, ['membership']);

    final detailsLastName = _buildLastName(
      _claimValue(details, ['paternalLastName']),
      _claimValue(details, ['maternalLastName']),
    );
    final detailsFullName = _buildFullName(
      _claimValue(details, ['firstName']),
      detailsLastName,
    );

    final fullNameFromClaims = _buildFullName(
      _claimValue(claims, ['name', 'firstName']),
      _claimValue(claims, ['lastName', 'paternalLastName']),
      fallback: _claimValue(claims, ['userName']),
    );
    final emailFromClaims = _claimValue(claims, ['mail', 'email']);
    final phoneFromClaims = _claimValue(claims, [
      'mobilePhone',
      'landlinePhone',
      'phone',
    ]);
    final rutFromClaims = _claimValue(claims, [
      'memberId',
      'rut',
      'documentId',
    ]);

    // Keep an already-resolved value when fresh claims don't carry one,
    // matching the previous `copyWith(field ?? this.field)` semantics.
    fullName = detailsFullName ?? fullNameFromClaims ?? fullName;
    email = _claimValue(details, ['email']) ?? emailFromClaims ?? email;
    phone =
        _claimValue(details, ['mobilePhone', 'landlinePhone']) ??
        phoneFromClaims ??
        phone;
    rut = _claimValue(details, ['memberId']) ?? rutFromClaims ?? rut;
    selectedMembership = membershipFromClaims ?? selectedMembership;

    notifyListeners();
  }

  String? _claimValue(Map<String, dynamic> claims, List<String> keys) {
    for (final key in keys) {
      final value = claims[key];
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          return trimmed;
        }
      }
    }
    return null;
  }

  Map<String, dynamic> _claimMap(
    Map<String, dynamic> claims,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = claims[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return const <String, dynamic>{};
  }

  String? _buildFullName(String? name, String? lastName, {String? fallback}) {
    final normalizedName = _nonEmpty(name);
    final normalizedLastName = _nonEmpty(lastName);
    if (normalizedName != null && normalizedLastName != null) {
      return '$normalizedName $normalizedLastName';
    }
    if (normalizedName != null) {
      return normalizedName;
    }
    if (normalizedLastName != null) {
      return normalizedLastName;
    }
    return _nonEmpty(fallback);
  }

  String? _buildLastName(String? paternalLastName, String? maternalLastName) {
    final paternal = _nonEmpty(paternalLastName);
    final maternal = _nonEmpty(maternalLastName);
    if (paternal != null && maternal != null) {
      return '$paternal $maternal';
    }
    if (paternal != null) {
      return paternal;
    }
    if (maternal != null) {
      return maternal;
    }
    return null;
  }

  String? _nonEmpty(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
