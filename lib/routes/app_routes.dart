import 'package:go_router/go_router.dart';

import '../features/forgot_password/presentation/screens/forgot_password_stub_screen.dart';
import '../features/login/presentation/screens/login_screen.dart';
import '../features/main_shell/presentation/screens/guest_placeholder_screen.dart';
import '../features/otp/domain/otp_context.dart';
import '../features/otp/presentation/screens/otp_screen.dart';
import '../features/registration/presentation/screens/registration_stub_screen.dart';

/// Centralized route names. Screens navigate via these constants rather
/// than hard-coded path strings, and no route is renamed/removed here
/// without updating every call site.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String otp = '/otp';
  static const String registration = '/registration';
  static const String forgotPassword = '/forgot-password';
  static const String guestHome = '/guest';
}

/// Arguments passed to [AppRoutes.otp] via `extra`, since the OTP screen is
/// parametrized by both the phone number and which flow launched it.
class OtpRouteArgs {
  const OtpRouteArgs({required this.localPhoneNumber, required this.context});

  final String localPhoneNumber;
  final OtpContext context;
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final args = state.extra as OtpRouteArgs;
        return OtpScreen(
          localPhoneNumber: args.localPhoneNumber,
          otpContext: args.context,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.registration,
      builder: (context, state) => const RegistrationStubScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordStubScreen(),
    ),
    GoRoute(
      path: AppRoutes.guestHome,
      builder: (context, state) => const GuestPlaceholderScreen(),
    ),
  ],
);
