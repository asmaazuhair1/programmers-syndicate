import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ips_app/core/utils/flavor_helper.dart';
import 'package:ips_app/main_app.dart';

void main() {
  testWidgets('Login screen renders phone field and primary actions', (tester) async {
    FlavorConfig.initialize(Flavor.ipsUat);
    await tester.pumpWidget(const IpsApp());
    await tester.pumpAndSettle();

    expect(find.text('رقم الهاتف'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('الدخول كضيف'), findsOneWidget);

    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });
}
