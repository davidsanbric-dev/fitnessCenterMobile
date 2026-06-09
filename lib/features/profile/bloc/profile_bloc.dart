import 'package:portfolio_mobile_app/app/core/api/memberships_api.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/features/profile/bloc/profile_event.dart';
import 'package:portfolio_mobile_app/features/profile/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({MembershipsApi? membershipsApi, AuthApi? authApi})
    : _membershipsApi = membershipsApi ?? MembershipsApi(),
      _authApi = authApi ?? _resolveAuthApi(),
      super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileMembershipFocusChanged>(_onMembershipFocusChanged);
    on<ProfileMembershipsRequested>(_onMembershipsRequested);
    on<ProfileMembershipSelected>(_onMembershipSelected);
    on<ProfileSheetDismissed>(_onSheetDismissed);
  }

  final MembershipsApi _membershipsApi;
  final AuthApi _authApi;

  static AuthApi _resolveAuthApi() {
    if (Get.isRegistered<AuthApi>()) {
      return Get.find<AuthApi>();
    }
    return AuthApi();
  }

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    var cachedUser = await _authApi.getCachedUser();
    if ((cachedUser == null || cachedUser.isEmpty) &&
        _authApi.hasFirebaseSession) {
      cachedUser = await _authApi.restoreSessionFromFirebase();
    }
    if (cachedUser == null || cachedUser.isEmpty) {
      return;
    }

    // Paint the fields from the cached claims right away. Name/email/phone/rut
    // are already present locally, so the user sees them without waiting on the
    // (multi-round-trip) Firebase session refresh below.
    emit(_stateFromClaims(cachedUser));

    // Only force a session refresh when the cached payload is structurally
    // incomplete (no `details` map). A missing membership claim is not a reason
    // to refresh: the session pipeline never writes one, so refreshing for it
    // would pay the network cost on every visit without ever resolving it.
    final details = _claimMap(cachedUser, ['details', 'Details']);
    if (details.isEmpty && _authApi.hasFirebaseSession) {
      final refreshedClaims = await _authApi.restoreSessionFromFirebase();
      if (refreshedClaims != null && refreshedClaims.isNotEmpty) {
        emit(_stateFromClaims(refreshedClaims));
      }
    }
  }

  ProfileState _stateFromClaims(Map<String, dynamic> claims) {
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

    return state.copyWith(
      fullName: detailsFullName ?? fullNameFromClaims,
      email: _claimValue(details, ['email']) ?? emailFromClaims,
      phone:
          _claimValue(details, ['mobilePhone', 'landlinePhone']) ??
          phoneFromClaims,
      rut: _claimValue(details, ['memberId']) ?? rutFromClaims,
      selectedMembership: membershipFromClaims,
    );
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

  void _onMembershipFocusChanged(
    ProfileMembershipFocusChanged event,
    Emitter<ProfileState> emit,
  ) {
    if (!event.hasFocus) {
      if (state.isSheetVisible) {
        emit(state.copyWith(isSheetVisible: false));
      }
      return;
    }

    if (!state.isSheetVisible) {
      emit(state.copyWith(isSheetVisible: true));
    }
    add(const ProfileMembershipsRequested());
  }

  Future<void> _onMembershipsRequested(
    ProfileMembershipsRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }
    if (!event.forceRefresh &&
        state.hasLoadedMemberships &&
        state.error == null &&
        state.memberships.isNotEmpty) {
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _membershipsApi.getMemberships();
      emit(
        state.copyWith(
          memberships: response,
          hasLoadedMemberships: true,
          isLoading: false,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          memberships: const [],
          hasLoadedMemberships: true,
          isLoading: false,
          error: err.userErrorMessageWith(
            'Error inesperado al cargar membershipes',
          ),
        ),
      );
    }
  }

  void _onMembershipSelected(
    ProfileMembershipSelected event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(selectedMembership: event.value, isSheetVisible: false),
    );
  }

  void _onSheetDismissed(
    ProfileSheetDismissed event,
    Emitter<ProfileState> emit,
  ) {
    if (state.isSheetVisible) {
      emit(state.copyWith(isSheetVisible: false));
    }
  }
}
