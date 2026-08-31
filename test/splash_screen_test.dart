import 'package:flutter_test/flutter_test.dart';

import 'package:ips_app/core/utils/flavor_helper.dart';
import 'package:ips_app/core/widgets/ips_shield_emblem.dart';
import 'package:ips_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:ips_app/main_app.dart';
import 'package:ips_app/routes/app_routes.dart';

void main() {
  testWidgets(
    'Splash screen shows the brand mark and app name, then hands off to '
    'Welcome once its hold duration elapses',
    (tester) async {
      FlavorConfig.initialize(Flavor.ipsUat);
      // appRouter is a process-wide singleton; force it back to splash so
      // an earlier test's navigation doesn't leak into this one.
      appRouter.go(AppRoutes.splash);
      await tester.pumpWidget(const IpsApp());
      // Avoid pumpAndSettle: the dot loader runs a repeating animation for
      // as long as the splash is on screen. A bounded pump past the
      // one-shot entrance (900ms) is enough to assert on-screen content.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.byType(IpsShieldEmblem), findsOneWidget);
      expect(find.text('نقابة المبرمجين العراقيين'), findsOneWidget);
      expect(find.text('Iraqi Programmers Syndicate'), findsOneWidget);

      // Advance past the hold duration; the Timer should fire and route to
      // Welcome via context.go.
      await tester.pump(SplashScreen.holdDuration);
      await tester.pump();
      // Land on Welcome; avoid pumpAndSettle since Welcome has its own
      // repeating animations that never settle.
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
