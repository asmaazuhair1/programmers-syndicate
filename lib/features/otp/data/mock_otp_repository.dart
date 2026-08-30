import '../../../core/network/api_result.dart';
import '../domain/otp_context.dart';
import 'otp_repository.dart';

/// Simulated OTP backend. Deterministic test codes let QA reach every
/// state without a real SMS provider:
///  - "111111" -> invalid code
///  - "222222" -> expired code
///  - any other 6-digit code -> success
class MockOtpRepository implements OtpRepository {
  static const _invalidCode = '111111';
  static const _expiredCode = '222222';

  @override
  Future<ApiResult<void>> verifyOtp({
    required String localPhoneNumber,
    required String code,
    required OtpContext context,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (code == _invalidCode) {
      return const ApiFailure('رمز التحقق غير صحيح، الرجاء المحاولة مرة أخرى');
    }
    if (code == _expiredCode) {
      return const ApiFailure('انتهت صلاحية رمز التحقق، الرجاء طلب رمز جديد');
    }
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> resendOtp({
    required String localPhoneNumber,
    required OtpContext context,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const ApiSuccess(null);
  }
}
