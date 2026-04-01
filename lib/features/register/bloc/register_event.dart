import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterRutChanged extends RegisterEvent {
  const RegisterRutChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterBirthDayChanged extends RegisterEvent {
  const RegisterBirthDayChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterBirthMonthChanged extends RegisterEvent {
  const RegisterBirthMonthChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterBirthYearChanged extends RegisterEvent {
  const RegisterBirthYearChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterEmailChanged extends RegisterEvent {
  const RegisterEmailChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterLocationCodeChanged extends RegisterEvent {
  const RegisterLocationCodeChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterIdentificationTypeChanged extends RegisterEvent {
  const RegisterIdentificationTypeChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterMemberIdChanged extends RegisterEvent {
  const RegisterMemberIdChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterFirstNameChanged extends RegisterEvent {
  const RegisterFirstNameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterPaternalSurnameChanged extends RegisterEvent {
  const RegisterPaternalSurnameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterMaternalSurnameChanged extends RegisterEvent {
  const RegisterMaternalSurnameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterCellPhoneChanged extends RegisterEvent {
  const RegisterCellPhoneChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterLandlinePhoneChanged extends RegisterEvent {
  const RegisterLandlinePhoneChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterAddressChanged extends RegisterEvent {
  const RegisterAddressChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterSignedDocumentIdChanged extends RegisterEvent {
  const RegisterSignedDocumentIdChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterPasswordChanged extends RegisterEvent {
  const RegisterPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterConfirmPasswordChanged extends RegisterEvent {
  const RegisterConfirmPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}

class RegisterTermsOpened extends RegisterEvent {
  const RegisterTermsOpened();
}

class RegisterTermsScrollChanged extends RegisterEvent {
  const RegisterTermsScrollChanged({required this.hasReachedEnd});

  final bool hasReachedEnd;

  @override
  List<Object?> get props => [hasReachedEnd];
}

class RegisterTermsSigned extends RegisterEvent {
  const RegisterTermsSigned({required this.hasSigned});

  final bool hasSigned;

  @override
  List<Object?> get props => [hasSigned];
}

class RegisterVerificationStarted extends RegisterEvent {
  const RegisterVerificationStarted({this.validFor});

  final String? validFor;

  @override
  List<Object?> get props => [validFor];
}

class RegisterVerificationTicked extends RegisterEvent {
  const RegisterVerificationTicked();
}

class RegisterVerificationDigitChanged extends RegisterEvent {
  const RegisterVerificationDigitChanged({
    required this.index,
    required this.value,
  });

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}
