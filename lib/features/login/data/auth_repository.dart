import '../../../core/network/api_result.dart';

/// Auth contract consumed by [LoginCubit]. A real implementation (backed by
/// the syndicate's API) can replace [MockAuthRepository] without any change
/// to the Cubit or UI.
abstract class AuthRepository {
  /// Requests an OTP be sent to [localPhoneNumber] (10 digits, no +964
  /// prefix, no leading zero). Returns success once the OTP has been
  /// dispatched, or a failure with a user-facing Arabic message.
  Future<ApiResult<void>> requestLoginOtp(String localPhoneNumber);
}
