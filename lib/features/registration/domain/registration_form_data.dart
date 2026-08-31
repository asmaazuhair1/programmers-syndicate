/// Snapshot of the registration form's field values at submit time. Built
/// by the screen from its local controllers/selections and handed to
/// [RegistrationCubit.submit] so validation/submission logic stays out of
/// the widget.
class RegistrationFormData {
  const RegistrationFormData({
    required this.firstName,
    required this.fatherName,
    required this.grandfatherName,
    required this.rawPhoneInput,
    required this.governorate,
    required this.gender,
    required this.birthDate,
  });

  final String firstName;
  final String fatherName;
  final String grandfatherName;

  /// Raw text from the phone field (not yet normalized).
  final String rawPhoneInput;

  final String? governorate;
  final String? gender;
  final DateTime? birthDate;
}
