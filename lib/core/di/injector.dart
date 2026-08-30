import '../../features/login/data/auth_repository.dart';
import '../../features/login/data/mock_auth_repository.dart';
import '../../features/otp/data/mock_otp_repository.dart';
import '../../features/otp/data/otp_repository.dart';

/// Minimal manual dependency injection. At this project's size a service
/// locator package would be unnecessary ceremony — this just centralizes
/// repository construction so screens/routes don't `new` implementations
/// directly, keeping the swap to a real API a one-line change per method.
class Injector {
  Injector._();

  static final Injector instance = Injector._();

  late final AuthRepository authRepository = MockAuthRepository();
  late final OtpRepository otpRepository = MockOtpRepository();
}
