import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/widgets/ips_app_bar.dart';
import '../../../../routes/app_routes.dart';

/// Temporary landing screen reached after guest login or a successful OTP
/// verification. The real main app shell (embedded WebView, notifications,
/// checkout, etc.) is a separate sub-project — this only proves the
/// navigation handoff works end-to-end.
class GuestPlaceholderScreen extends StatelessWidget {
  const GuestPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IpsAppBar(title: 'نقابة المبرمجين العراقيين', automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(IpsSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 48, color: IpsColors.success),
              const SizedBox(height: IpsSpacing.lg),
              Text('تم تسجيل الدخول بنجاح', style: Theme.of(context).textTheme.titleMedium),
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
