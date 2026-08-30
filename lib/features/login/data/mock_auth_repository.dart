import '../../../core/network/api_result.dart';
import 'auth_repository.dart';

/// Simulated backend for local development. Stands in until the real
/// syndicate API is available; behavior is deliberately deterministic so
/// QA can exercise every state:
///  - a number ending in "0000000" simulates a network failure.
///  - every other valid number succeeds.
class MockAuthRepository implements AuthRepository {
  static const _simulatedFailureSuffix = '0000000';

  @override
  Future<ApiResult<void>> requestLoginOtp(String localPhoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (localPhoneNumber.endsWith(_simulatedFailureSuffix)) {
      return const ApiFailure('تعذر الاتصال بالخادم، الرجاء المحاولة لاحقاً');
    }

    return const ApiSuccess(null);
  }
}
