import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileMembershipsRequested extends ProfileEvent {
  const ProfileMembershipsRequested({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

class ProfileMembershipFocusChanged extends ProfileEvent {
  const ProfileMembershipFocusChanged({required this.hasFocus});

  final bool hasFocus;

  @override
  List<Object?> get props => [hasFocus];
}

class ProfileMembershipSelected extends ProfileEvent {
  const ProfileMembershipSelected({required this.value});

  final String value;

  @override
  List<Object?> get props => [value];
}

class ProfileSheetDismissed extends ProfileEvent {
  const ProfileSheetDismissed();
}
