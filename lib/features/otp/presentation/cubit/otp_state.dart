enum OtpStatus { idle, submitting, success, error, resending }

/// A single composite state (rather than one sealed class per status) since
/// the resend countdown ticks independently of the verification outcome —
/// both need to be visible to the UI at once (e.g. an error shown while the
/// countdown keeps running).
class OtpState {
  const OtpState({
    this.status = OtpStatus.idle,
    this.errorMessage,
    this.resendSecondsRemaining = 60,
  });

  final OtpStatus status;
  final String? errorMessage;
  final int resendSecondsRemaining;

  bool get canResend => resendSecondsRemaining <= 0;

  OtpState copyWith({
    OtpStatus? status,
    String? errorMessage,
    bool clearError = false,
    int? resendSecondsRemaining,
  }) {
    return OtpState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      resendSecondsRemaining: resendSecondsRemaining ?? this.resendSecondsRemaining,
    );
  }
}
