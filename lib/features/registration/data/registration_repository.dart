import '../../../core/network/api_result.dart';
import '../domain/registration_form_data.dart';

/// Registration contract consumed by [RegistrationCubit]. A real
/// implementation (backed by the syndicate's API) can replace
/// [MockRegistrationRepository] without any change to the Cubit or UI.
abstract class RegistrationRepository {
  Future<ApiResult<void>> submitRegistration(RegistrationFormData data);
}
