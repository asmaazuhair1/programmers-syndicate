import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_styles/ips_theme.dart';
import 'core/utils/flavor_helper.dart';
import 'routes/app_routes.dart';

/// Shared bootstrap for every IPS flavor entry point. Flavor-specific
/// `main_*.dart` files only need to call [FlavorConfig.initialize] and then
/// [runApp] this widget.
class IpsApp extends StatelessWidget {
  const IpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Reference the active flavor now so it's clear this widget expects
    // FlavorConfig to already be initialized by the entry point.
    FlavorConfig.flavor;

    return MaterialApp.router(
      title: 'نقابة المبرمجين العراقيين',
      debugShowCheckedModeBanner: false,
      theme: IpsTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: appRouter,
    );
  }
}
