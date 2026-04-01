class CreateUserRequest {
  static const String defaultRoleId = '2e1ce908-bb14-41b2-9bf9-09f06e0d9f9c';
  static const String defaultMembership = 'FONDO NACIONAL DE SALUD';

  const CreateUserRequest({
    required this.name,
    required this.lastName,
    required this.mail,
    required this.identificationType,
    required this.memberId,
    required this.firstName,
    required this.paternalLastName,
    required this.maternalLastName,
    this.landlinePhone = '',
    required this.mobilePhone,
    required this.dateOfBirth,
    required this.address,
    this.membership = defaultMembership,
    required this.documentId,
    required this.password,
  });

  factory CreateUserRequest.forMemberRegistration({
    required String mail,
    required String dateOfBirth,
    required String identificationType,
    required String memberId,
    required String firstName,
    required String paternalLastName,
    required String maternalLastName,
    String landlinePhone = '',
    required String mobilePhone,
    required String address,
    String membership = defaultMembership,
    required String documentId,
    required String password,
  }) {
    final normalizedFirstName = firstName.trim();
    final normalizedPaternalLastName = paternalLastName.trim();
    final normalizedMaternalLastName = maternalLastName.trim();
    final normalizedLastName = [
      normalizedPaternalLastName,
      normalizedMaternalLastName,
    ].where((item) => item.isNotEmpty).join(' ');

    return CreateUserRequest(
      name: normalizedFirstName,
      lastName: normalizedLastName,
      mail: mail.trim(),
      identificationType: identificationType.trim(),
      memberId: memberId.trim(),
      firstName: normalizedFirstName,
      paternalLastName: normalizedPaternalLastName,
      maternalLastName: normalizedMaternalLastName,
      landlinePhone: landlinePhone.trim(),
      mobilePhone: mobilePhone.trim(),
      dateOfBirth: dateOfBirth.trim(),
      address: address.trim(),
      membership: membership.trim().isEmpty
          ? defaultMembership
          : membership.trim(),
      documentId: documentId.trim(),
      password: password,
    );
  }

  final String name;
  final String lastName;
  final String mail;
  final String identificationType;
  final String memberId;
  final String firstName;
  final String paternalLastName;
  final String maternalLastName;
  final String landlinePhone;
  final String mobilePhone;
  final String dateOfBirth;
  final String address;
  final String membership;
  final String documentId;
  final String password;

  Map<String, dynamic> toJson() {
    final normalizedMembership = membership.trim();

    return <String, dynamic>{
      'name': name.trim(),
      'lastName': lastName.trim(),
      'mail': mail.trim(),
      'roleId': defaultRoleId,
      'identificationType': identificationType.trim(),
      'memberId': memberId.trim(),
      'firstName': firstName.trim(),
      'paternalLastName': paternalLastName.trim(),
      'maternalLastName': maternalLastName.trim(),
      'landlinePhone': landlinePhone.trim(),
      'mobilePhone': mobilePhone.trim(),
      'dateOfBirth': dateOfBirth.trim(),
      'address': address.trim(),
      'membership': normalizedMembership.isEmpty
          ? defaultMembership
          : normalizedMembership,
      'documentId': documentId.trim(),
    };
  }

  Map<String, dynamic> toRegisterRequestBody() {
    return <String, dynamic>{
      'email': mail.trim(),
      'password': password,
      'first_name': firstName.trim(),
      'paternal_surname': paternalLastName.trim(),
      'maternal_surname': maternalLastName.trim(),
      'mobile_phone': mobilePhone.trim(),
      'landline_phone': landlinePhone.trim().isEmpty
          ? null
          : landlinePhone.trim(),
      'birth_date': dateOfBirth.trim().isEmpty ? null : dateOfBirth.trim(),
      'address': address.trim().isEmpty ? null : address.trim(),
    };
  }
}
