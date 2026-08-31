import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ips_app/core/utils/flavor_helper.dart';
import 'package:ips_app/core/widgets/ips_date_field.dart';
import 'package:ips_app/core/widgets/ips_dropdown_field.dart';
import 'package:ips_app/core/widgets/ips_phone_field.dart';
import 'package:ips_app/features/otp/presentation/widgets/otp_segmented_input.dart';
import 'package:ips_app/main_app.dart';
import 'package:ips_app/routes/app_routes.dart';

void main() {
  testWidgets(
    'Welcome screen renders title, phone field, and entry actions '
    '(Login is merged into Welcome; there is no separate Login screen)',
    (tester) async {
      FlavorConfig.initialize(Flavor.ipsUat);
      // The app now boots on the Splash screen (appRouter is a process-wide
      // singleton, so a prior test's navigation could also leak in); force
      // it to Welcome before pumping so this test isn't stuck waiting out
      // the splash's hold timer.
      appRouter.go(AppRoutes.welcome);
      await tester.pumpWidget(const IpsApp());
      // Avoid pumpAndSettle: the Welcome screen's aurora background and
      // button idle glow are repeating animations that never settle. A
      // bounded pump past the one-shot entrance sequence (900ms) is enough.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('نقابة المبرمجين العراقيين'), findsOneWidget);
      expect(find.byType(IpsPhoneField), findsOneWidget);
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.text('الدخول كضيف'), findsOneWidget);

      final directionality = tester.widget<Directionality>(
        find.byType(Directionality).first,
      );
      expect(directionality.textDirection, TextDirection.rtl);
    },
  );

  testWidgets(
    'Full flow: Welcome (login) -> OTP -> Registration -> Home',
    (tester) async {
      FlavorConfig.initialize(Flavor.ipsUat);
      // appRouter is a process-wide singleton, so an earlier test's
      // navigation would otherwise leak into this one; force it back to
      // the welcome screen before pumping.
      appRouter.go(AppRoutes.welcome);
      await tester.pumpWidget(const IpsApp());
      // Avoid pumpAndSettle here too: same repeating Welcome animations.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Fill a valid phone number (must not end in the mock "0000000"
      // failure suffix) and submit, directly on the Welcome screen (Login
      // is merged into it; there is no separate navigation hop).
      await tester.enterText(
        find.descendant(
          of: find.byType(IpsPhoneField),
          matching: find.byType(TextFormField),
        ),
        '7711234567',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'تسجيل الدخول'));

      // Mock auth repository resolves after 900ms.
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump();

      // Now on the OTP screen. Avoid pumpAndSettle: the resend countdown
      // runs a Timer.periodic(1s) for the lifetime of this screen.
      expect(find.text('+964 7711234567'), findsOneWidget);

      final otpFields = find.descendant(
        of: find.byType(OtpSegmentedInput),
        matching: find.byType(TextField),
      );
      expect(otpFields, findsNWidgets(6));
      // Any code other than the mocked failure codes (111111 / 222222)
      // succeeds.
      const code = '345678';
      for (var i = 0; i < code.length; i++) {
        await tester.enterText(otpFields.at(i), code[i]);
        await tester.pump();
      }

      // Mock OTP repository resolves after 900ms.
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump();

      // OTP context.login success -> Registration screen, phone prefilled
      // and locked. Avoid pumpAndSettle from here on while Registration is
      // mounted: it now shares OTP's repeating backdrop/security-frame
      // animations, which never settle. A bounded pump past the frame's
      // one-shot entrance (750ms) is enough.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('إنشاء حساب'), findsOneWidget);
      // The phone field is intentionally not shown on Registration: the
      // number is already verified via OTP before this screen is reached,
      // so it's carried silently and submitted without a visible field.
      expect(find.byType(IpsPhoneField), findsNothing);

      Finder textFieldNearLabel(String label) {
        final nearestColumn = find
            .ancestor(of: find.textContaining(label), matching: find.byType(Column))
            .first;
        return find.descendant(of: nearestColumn, matching: find.byType(TextFormField));
      }

      await tester.enterText(textFieldNearLabel('الاسم الأول').first, 'أحمد');
      await tester.enterText(textFieldNearLabel('اسم الأب').first, 'محمد');
      await tester.enterText(textFieldNearLabel('اسم الجد').first, 'علي');

      await tester.ensureVisible(find.byType(IpsDropdownField<String>).first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byType(IpsDropdownField<String>).first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('بغداد').last);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(find.byType(IpsDropdownField<String>).at(1));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byType(IpsDropdownField<String>).at(1));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('ذكر').last);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(find.byType(IpsDateField));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byType(IpsDateField));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('حسنًا'));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.widgetWithText(ElevatedButton, 'التالي'));
      // Mock registration repository resolves after 900ms.
      await tester.pump(const Duration(milliseconds: 1000));
      // Registration success navigates to Home, which has no repeating
      // animations, so pumpAndSettle is safe again from here.
      await tester.pumpAndSettle();

      // Registration success -> Home screen.
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('مرحباً بك في نقابة المبرمجين العراقيين'), findsOneWidget);
    },
  );

  testWidgets(
    'Registration screen after verified-OTP login shows an explicit back '
    'button that navigates to Welcome instead of popping '
    '(regression: OTP login success replaces the stack via context.go, '
    'leaving nothing to pop, so the screen provides its own leading '
    "back icon that routes via context.go rather than relying on the "
    "AppBar's implicit pop-based back arrow.)",
    (tester) async {
      FlavorConfig.initialize(Flavor.ipsUat);
      appRouter.go(
        AppRoutes.registration,
        extra: const RegistrationRouteArgs(initialLocalPhoneNumber: '7711234567'),
      );
      await tester.pumpWidget(const IpsApp());
      // Avoid pumpAndSettle: Registration's backdrop/security-frame
      // animations repeat and never settle. A bounded pump past the
      // frame's one-shot entrance (750ms) is enough.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('إنشاء حساب'), findsOneWidget);
      expect(appRouter.canPop(), isFalse);

      // Explicit leading back icon is rendered despite nothing to pop.
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.arrow_back));
      // Avoid pumpAndSettle: back navigation lands on the Welcome screen,
      // whose backdrop constellation/glow are repeating animations that
      // never settle. A bounded pump past the one-shot entrance sequence
      // (1000ms) is enough, matching the pattern used above.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('نقابة المبرمجين العراقيين'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
