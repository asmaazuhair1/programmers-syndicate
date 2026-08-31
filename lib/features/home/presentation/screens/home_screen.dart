import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/widgets/ips_app_bar.dart';
import '../../../../routes/app_routes.dart';

/// Landing screen reached after a member completes phone verification and
/// the personal-information form. The real main app shell (embedded
/// WebView, notifications, checkout, etc.) is a separate sub-project — this
/// only proves the end-to-end navigation handoff works and gives
/// authenticated users a real destination distinct from the guest
/// placeholder.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IpsAppBar(title: 'الرئيسية', automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(IpsSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_outlined, size: 48, color: IpsColors.success),
              const SizedBox(height: IpsSpacing.lg),
              Text(
                'مرحباً بك في نقابة المبرمجين العراقيين',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IpsSpacing.sm),
              Text(
                'الواجهة الرئيسية للتطبيق (WebView، الإشعارات، الدفع) قيد التطوير ضمن المرحلة التالية',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IpsSpacing.xxl),
              TextButton(
                onPressed: () => context.go(AppRoutes.welcome),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
