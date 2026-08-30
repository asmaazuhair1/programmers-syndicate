import '../../../core/network/api_result.dart';
import '../domain/otp_context.dart';

/// OTP contract consumed by [OtpCubit]. Verification and resend failures
/// surface as [ApiFailure] with an Arabic message already appropriate for
/// display (e.g. distinguishing an invalid code from an expired one).
abstract class OtpRepository {
  Future<ApiResult<void>> verifyOtp({
    required String localPhoneNumber,
    required String code,
    required OtpContext context,
  });

  Future<ApiResult<void>> resendOtp({
    required String localPhoneNumber,
    required OtpContext context,
  });
}
