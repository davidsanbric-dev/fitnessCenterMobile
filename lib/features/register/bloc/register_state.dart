import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/input.dart';
import 'package:portfolio_mobile_app/app/core/utils/validate.dart';
import 'package:equatable/equatable.dart';

class RegisterState extends Equatable {
  static const int verificationCodeLength = 6;
  static const List<String> emptyVerificationCodeDigits = [
    '',
    '',
    '',
    '',
    '',
    '',
  ];

  const RegisterState({
    this.rut = '',
    this.birthDay = '',
    this.birthMonth = '',
    this.birthYear = '',
    this.email = '',
    this.locationCode = '1',
    this.identificationType = '',
    this.memberId = '',
    this.firstName = '',
    this.paternalSurname = '',
    this.maternalSurname = '',
    this.cellPhone = '',
    this.landlinePhone = '',
    this.address = '',
    this.signedDocumentId = '',
    this.password = '',
    this.confirmPassword = '',
    this.hasReachedTermsEnd = false,
    this.hasSignedTerms = false,
    this.showErrors = true,
    this.verificationCodeDigits = emptyVerificationCodeDigits,
    this.verificationRemaining = const Duration(minutes: 30),
  });

  final String rut;
  final String birthDay;
  final String birthMonth;
  final String birthYear;
  final String email;
  final String locationCode;
  final String identificationType;
  final String memberId;
  final String firstName;
  final String paternalSurname;
  final String maternalSurname;
  final String cellPhone;
  final String landlinePhone;
  final String address;
  final String signedDocumentId;
  final String password;
  final String confirmPassword;
  final bool hasReachedTermsEnd;
  final bool hasSignedTerms;
  final bool showErrors;
  final List<String> verificationCodeDigits;
  final Duration verificationRemaining;

  bool get hasRut => rut.trim().isNotEmpty;
  bool get hasMemberId => memberId.trim().isNotEmpty;

  bool get isRutValid => isNormalizedRutValid(rut);

  bool get isDayValid => isDayValidValue(birthDay);
  bool get isMonthValid => isMonthValidValue(birthMonth);
  bool get isYearValid => isYearValidValue(birthYear);

  bool get isBirthDateValid =>
      isBirthDateValidValue(day: birthDay, month: birthMonth, year: birthYear);

  bool get isEmailValid => isEmailValidValue(email);

  bool get canContinue => isRutValid && isBirthDateValid && isEmailValid;

  bool get canContinueThirdStep =>
      firstName.trim().isNotEmpty &&
      paternalSurname.trim().isNotEmpty &&
      maternalSurname.trim().isNotEmpty &&
      identificationType.trim().isNotEmpty &&
      memberId.trim().isNotEmpty &&
      cellPhone.trim().isNotEmpty &&
      address.trim().isNotEmpty;

  bool get passwordHasMinLength => password.length >= 8;
  bool get passwordHasUppercase => passHasUppercase(password);
  bool get passwordHasLowercase => passHasLowercase(password);
  bool get passwordHasNumber => passHasNumber(password);
  bool get passwordHasSymbol => passHasSymbol(password);
  bool get passwordHasAlphaNumeric => passHasAlphaNumeric(password);

  bool get isPasswordValid =>
      passwordHasAlphaNumeric &&
      passwordHasUppercase &&
      passwordHasLowercase &&
      passwordHasNumber &&
      passwordHasSymbol;

  bool get doesConfirmPasswordMatch =>
      confirmPassword.isNotEmpty && confirmPassword == password;

  bool get canContinuePassword => isPasswordValid && doesConfirmPasswordMatch;

  String? get confirmPasswordError {
    if (confirmPassword.isEmpty) {
      return null;
    }
    if (!doesConfirmPasswordMatch) return 'Passwords do not match.';

    return null;
  }

  String? get rutError {
    if (!showErrors) {
      return null;
    }
    if (!hasRut) return 'This field is required.';
    if (!isRutValid) return 'Enter a valid ID.';

    return null;
  }

  bool get showRutErrorIcon => rutError != null;

  bool get isVerificationCodeComplete =>
      verificationCodeDigits.every((digit) => digit.trim().isNotEmpty);

  String get verificationCode => verificationCodeDigits.join();

  String get maskedEmail => maskEmail(email);

  String get formattedVerificationRemaining =>
      formatRemaining(verificationRemaining);

  bool get canVerifyIdentity => isRutValid && hasMemberId;
  bool get hasSignedDocumentId => signedDocumentId.trim().isNotEmpty;

  RegisterState copyWith({
    String? rut,
    String? birthDay,
    String? birthMonth,
    String? birthYear,
    String? email,
    String? locationCode,
    String? identificationType,
    String? memberId,
    String? firstName,
    String? paternalSurname,
    String? maternalSurname,
    String? cellPhone,
    String? landlinePhone,
    String? address,
    String? signedDocumentId,
    String? password,
    String? confirmPassword,
    bool? hasReachedTermsEnd,
    bool? hasSignedTerms,
    bool? showErrors,
    List<String>? verificationCodeDigits,
    Duration? verificationRemaining,
  }) {
    return RegisterState(
      rut: rut ?? this.rut,
      birthDay: birthDay ?? this.birthDay,
      birthMonth: birthMonth ?? this.birthMonth,
      birthYear: birthYear ?? this.birthYear,
      email: email ?? this.email,
      locationCode: locationCode ?? this.locationCode,
      identificationType: identificationType ?? this.identificationType,
      memberId: memberId ?? this.memberId,
      firstName: firstName ?? this.firstName,
      paternalSurname: paternalSurname ?? this.paternalSurname,
      maternalSurname: maternalSurname ?? this.maternalSurname,
      cellPhone: cellPhone ?? this.cellPhone,
      landlinePhone: landlinePhone ?? this.landlinePhone,
      address: address ?? this.address,
      signedDocumentId: signedDocumentId ?? this.signedDocumentId,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      hasReachedTermsEnd: hasReachedTermsEnd ?? this.hasReachedTermsEnd,
      hasSignedTerms: hasSignedTerms ?? this.hasSignedTerms,
      showErrors: showErrors ?? this.showErrors,
      verificationCodeDigits:
          verificationCodeDigits ?? this.verificationCodeDigits,
      verificationRemaining:
          verificationRemaining ?? this.verificationRemaining,
    );
  }

  @override
  List<Object?> get props => [
    rut,
    birthDay,
    birthMonth,
    birthYear,
    email,
    locationCode,
    identificationType,
    memberId,
    firstName,
    paternalSurname,
    maternalSurname,
    cellPhone,
    landlinePhone,
    address,
    signedDocumentId,
    password,
    confirmPassword,
    hasReachedTermsEnd,
    hasSignedTerms,
    showErrors,
    verificationRemaining,
    ...verificationCodeDigits,
  ];
}
