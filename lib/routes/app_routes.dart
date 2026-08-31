import 'package:go_router/go_router.dart';

import '../features/forgot_password/presentation/screens/forgot_password_stub_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/main_shell/presentation/screens/guest_placeholder_screen.dart';
import '../features/otp/domain/otp_context.dart';
import '../features/otp/presentation/screens/otp_screen.dart';
import '../features/registration/presentation/screens/registration_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/welcome/presentation/screens/welcome_screen.dart';

/// Centralized route names. Screens navigate via these constants rather
/// than hard-coded path strings, and no route is renamed/removed here
/// without updating every call site.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String welcome = '/';
  static const String otp = '/otp';
  static const String registration = '/registration';
  static const String forgotPassword = '/forgot-password';
  static const String guestHome = '/guest';
  static const String home = '/home';
}

/// Arguments passed to [AppRoutes.otp] via `extra`, since the OTP screen is
/// parametrized by both the phone number and which flow launched it.
class OtpRouteArgs {
  const OtpRouteArgs({required this.localPhoneNumber, required this.context});

  final String localPhoneNumber;
  final OtpContext context;
}

/// Optional arguments passed to [AppRoutes.registration] via `extra`, used
/// when arriving from a verified login OTP so the phone field can be
/// prefilled and locked instead of re-entered.
class RegistrationRouteArgs {
  const RegistrationRouteArgs({this.initialLocalPhoneNumber});

  final String? initialLocalPhoneNumber;
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
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
      builder: (context, state) {
        final args = state.extra as RegistrationRouteArgs?;
        return RegistrationScreen(
          initialLocalPhoneNumber: args?.initialLocalPhoneNumber,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordStubScreen(),
    ),
    GoRoute(
      path: AppRoutes.guestHome,
      builder: (context, state) => const GuestPlaceholderScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
