import 'package:portfolio_mobile_app/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  static const Object _unset = Object();

  const ProfileState({
    this.memberships = const [],
    this.hasLoadedMemberships = false,
    this.isSheetVisible = false,
    this.isLoading = false,
    this.error,
    this.fullName,
    this.email,
    this.phone,
    this.rut,
    this.selectedMembership,
  });

  final List<MembershipDto> memberships;
  final bool hasLoadedMemberships;
  final bool isSheetVisible;
  final bool isLoading;
  final String? error;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? rut;
  final String? selectedMembership;

  List<String> get membershipOptions => memberships
      .map((item) => item.membershipName)
      .where((name) => name.trim().isNotEmpty)
      .toList(growable: false);

  ProfileState copyWith({
    List<MembershipDto>? memberships,
    bool? hasLoadedMemberships,
    bool? isSheetVisible,
    bool? isLoading,
    Object? error = _unset,
    String? fullName,
    String? email,
    String? phone,
    String? rut,
    String? selectedMembership,
  }) {
    return ProfileState(
      memberships: memberships ?? this.memberships,
      hasLoadedMemberships: hasLoadedMemberships ?? this.hasLoadedMemberships,
      isSheetVisible: isSheetVisible ?? this.isSheetVisible,
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rut: rut ?? this.rut,
      selectedMembership: selectedMembership ?? this.selectedMembership,
    );
  }

  @override
  List<Object?> get props => [
    memberships,
    hasLoadedMemberships,
    isSheetVisible,
    isLoading,
    error,
    fullName,
    email,
    phone,
    rut,
    selectedMembership,
  ];
}
