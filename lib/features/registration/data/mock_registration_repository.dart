import '../../../core/network/api_result.dart';
import '../domain/registration_form_data.dart';
import 'registration_repository.dart';

/// Simulated backend for local development. Always succeeds after a short
/// delay; stands in until the real syndicate API is available.
class MockRegistrationRepository implements RegistrationRepository {
  @override
  Future<ApiResult<void>> submitRegistration(RegistrationFormData data) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return const ApiSuccess(null);
  }
}
