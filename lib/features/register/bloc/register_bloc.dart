import 'dart:async';

import 'package:portfolio_mobile_app/app/core/utils/parse.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_event.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  static const Duration _defaultVerificationValidity = Duration(minutes: 30);
  static const Duration _verificationTick = Duration(seconds: 1);

  Timer? _verificationTimer;

  RegisterBloc() : super(const RegisterState()) {
    on<RegisterRutChanged>(_onRutChanged);
    on<RegisterBirthDayChanged>(_onBirthDayChanged);
    on<RegisterBirthMonthChanged>(_onBirthMonthChanged);
    on<RegisterBirthYearChanged>(_onBirthYearChanged);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterLocationCodeChanged>(_onLocationCodeChanged);
    on<RegisterIdentificationTypeChanged>(_onIdentificationTypeChanged);
    on<RegisterMemberIdChanged>(_onMemberIdChanged);
    on<RegisterFirstNameChanged>(_onFirstNameChanged);
    on<RegisterPaternalSurnameChanged>(_onPaternalSurnameChanged);
    on<RegisterMaternalSurnameChanged>(_onMaternalSurnameChanged);
    on<RegisterCellPhoneChanged>(_onCellPhoneChanged);
    on<RegisterLandlinePhoneChanged>(_onLandlinePhoneChanged);
    on<RegisterAddressChanged>(_onAddressChanged);
    on<RegisterSignedDocumentIdChanged>(_onSignedDocumentIdChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegisterTermsOpened>(_onTermsOpened);
    on<RegisterTermsScrollChanged>(_onTermsScrollChanged);
    on<RegisterTermsSigned>(_onTermsSigned);
    on<RegisterSubmitted>(_onSubmitted);
    on<RegisterVerificationStarted>(_onVerificationStarted);
    on<RegisterVerificationTicked>(_onVerificationTicked);
    on<RegisterVerificationDigitChanged>(_onVerificationDigitChanged);
  }

  void _onRutChanged(RegisterRutChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(rut: event.value));
  }

  void _onBirthDayChanged(
    RegisterBirthDayChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(birthDay: event.value));
  }

  void _onBirthMonthChanged(
    RegisterBirthMonthChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(birthMonth: event.value));
  }

  void _onBirthYearChanged(
    RegisterBirthYearChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(birthYear: event.value));
  }

  void _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(email: event.value));
  }

  void _onLocationCodeChanged(
    RegisterLocationCodeChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(locationCode: event.value));
  }

  void _onIdentificationTypeChanged(
    RegisterIdentificationTypeChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(identificationType: event.value));
  }

  void _onMemberIdChanged(
    RegisterMemberIdChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(memberId: event.value));
  }

  void _onFirstNameChanged(
    RegisterFirstNameChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(firstName: event.value));
  }

  void _onPaternalSurnameChanged(
    RegisterPaternalSurnameChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(paternalSurname: event.value));
  }

  void _onMaternalSurnameChanged(
    RegisterMaternalSurnameChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(maternalSurname: event.value));
  }

  void _onCellPhoneChanged(
    RegisterCellPhoneChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(cellPhone: event.value));
  }

  void _onLandlinePhoneChanged(
    RegisterLandlinePhoneChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(landlinePhone: event.value));
  }

  void _onAddressChanged(
    RegisterAddressChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(address: event.value));
  }

  void _onSignedDocumentIdChanged(
    RegisterSignedDocumentIdChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(signedDocumentId: event.value));
  }

  void _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(password: event.value));
  }

  void _onConfirmPasswordChanged(
    RegisterConfirmPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.value));
  }

  void _onTermsOpened(RegisterTermsOpened event, Emitter<RegisterState> emit) {
    if (!state.hasReachedTermsEnd && !state.hasSignedTerms) {
      return;
    }
    emit(state.copyWith(hasReachedTermsEnd: false, hasSignedTerms: false));
  }

  void _onTermsScrollChanged(
    RegisterTermsScrollChanged event,
    Emitter<RegisterState> emit,
  ) {
    if (state.hasReachedTermsEnd == event.hasReachedEnd) {
      return;
    }
    emit(state.copyWith(hasReachedTermsEnd: event.hasReachedEnd));
  }

  void _onTermsSigned(RegisterTermsSigned event, Emitter<RegisterState> emit) {
    if (state.hasSignedTerms == event.hasSigned) {
      return;
    }
    emit(state.copyWith(hasSignedTerms: event.hasSigned));
  }

  void _onSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) {
    emit(state.copyWith(showErrors: true));
  }

  void _onVerificationStarted(
    RegisterVerificationStarted event,
    Emitter<RegisterState> emit,
  ) {
    final Duration duration =
        parseValidFor(event.validFor) ?? _defaultVerificationValidity;
    _startVerificationTimer(duration);
    emit(
      state.copyWith(
        verificationRemaining: duration,
        verificationCodeDigits: List<String>.from(
          RegisterState.emptyVerificationCodeDigits,
        ),
      ),
    );
  }

  void _onVerificationTicked(
    RegisterVerificationTicked event,
    Emitter<RegisterState> emit,
  ) {
    if (state.verificationRemaining <= _verificationTick) {
      _verificationTimer?.cancel();
      emit(state.copyWith(verificationRemaining: Duration.zero));
      return;
    }
    emit(
      state.copyWith(
        verificationRemaining: state.verificationRemaining - _verificationTick,
      ),
    );
  }

  void _onVerificationDigitChanged(
    RegisterVerificationDigitChanged event,
    Emitter<RegisterState> emit,
  ) {
    if (event.index < 0 ||
        event.index >= RegisterState.verificationCodeLength) {
      return;
    }
    final String trimmed = event.value.trim();
    final String normalized = trimmed.isEmpty
        ? ''
        : trimmed.substring(trimmed.length - 1);
    final List<String> digits =
        state.verificationCodeDigits.length ==
            RegisterState.verificationCodeLength
        ? List<String>.from(state.verificationCodeDigits)
        : List<String>.from(RegisterState.emptyVerificationCodeDigits);
    digits[event.index] = normalized;
    emit(state.copyWith(verificationCodeDigits: digits));
  }

  void _startVerificationTimer(Duration duration) {
    _verificationTimer?.cancel();
    if (duration <= Duration.zero) {
      return;
    }
    _verificationTimer = Timer.periodic(_verificationTick, (_) {
      if (isClosed) {
        _verificationTimer?.cancel();
        return;
      }
      add(const RegisterVerificationTicked());
    });
  }

  @override
  Future<void> close() {
    _verificationTimer?.cancel();
    return super.close();
  }
}
