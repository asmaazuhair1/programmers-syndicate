/// [LoginCubit] states. Field-level validation is handled synchronously by
/// the form itself; these states cover the async request-OTP call only.
sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

/// OTP was requested successfully for [localPhoneNumber]; the screen
/// should navigate to the OTP screen in response to this state.
class LoginOtpRequested extends LoginState {
  const LoginOtpRequested(this.localPhoneNumber);

  final String localPhoneNumber;
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;
}
