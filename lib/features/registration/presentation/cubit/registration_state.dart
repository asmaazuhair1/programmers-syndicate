enum RegistrationStatus { initial, submitting, success, failure }

/// Field keys used in [RegistrationState.fieldErrors], matching the seven
/// registration form fields.
class RegistrationField {
  RegistrationField._();

  static const String firstName = 'firstName';
  static const String fatherName = 'fatherName';
  static const String grandfatherName = 'grandfatherName';
  static const String phone = 'phone';
  static const String governorate = 'governorate';
  static const String gender = 'gender';
  static const String birthDate = 'birthDate';
}

/// A single composite state (matching the [OtpState] pattern): submission
/// status plus per-field validation errors and an optional general failure
/// message (e.g. a simulated network failure), all visible to the UI at
/// once.
class RegistrationState {
  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.fieldErrors = const {},
    this.errorMessage,
  });

  final RegistrationStatus status;
  final Map<String, String> fieldErrors;
  final String? errorMessage;

  RegistrationState copyWith({
    RegistrationStatus? status,
    Map<String, String>? fieldErrors,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RegistrationState(
      status: status ?? this.status,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
