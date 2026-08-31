import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/ips_gold_button.dart';
import '../../../../core/widgets/ips_outlined_button.dart';
import '../../../../core/widgets/ips_phone_field.dart';
import '../../../../core/widgets/ips_pressable_scale.dart';
import '../../../../core/widgets/ips_screen_header.dart';
import '../../../../core/widgets/ips_security_frame.dart';
import '../../../../core/widgets/ips_snackbar.dart';
import '../../../../core/widgets/ips_technical_backdrop.dart';
import '../../../../routes/app_routes.dart';
import '../../../login/presentation/cubit/login_cubit.dart';
import '../../../login/presentation/cubit/login_state.dart';
import '../../../otp/domain/otp_context.dart';

/// First and only pre-auth screen: brand mark, title/subtitle, the phone
/// number field with its login action directly beneath it, and the guest
/// entry point. The former standalone Login screen is merged into this one
/// so users land on a single page instead of an extra navigation hop.
///
/// Shares the same light "security scanner" language as the OTP screen —
/// [IpsTechnicalBackdrop] behind an [IpsSecurityFrame] — so the hand-off
/// between Welcome, OTP, and Registration never breaks character.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(Injector.instance.authRepository),
      child: const _WelcomeView(),
    );
  }
}

class _WelcomeView extends StatefulWidget {
  const _WelcomeView();

  @override
  State<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<_WelcomeView> {
  final _phoneController = TextEditingController();
  String? _fieldError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<LoginCubit>().submitPhoneNumber(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IpsColors.surfaceMuted,
      // SizedBox.expand forces the Stack to always be exactly screen-sized,
      // matching the OTP screen shell so the backdrop bleeds to the true
      // full screen instead of shrinking to fit scrollable content.
      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned.fill(child: IpsTechnicalBackdrop()),
            SafeArea(
              child: BlocConsumer<LoginCubit, LoginState>(
                listener: (context, state) {
                  switch (state) {
                    case LoginOtpRequested(:final localPhoneNumber):
                      setState(() => _fieldError = null);
                      context.push(
                        AppRoutes.otp,
                        extra: OtpRouteArgs(
                          localPhoneNumber: localPhoneNumber,
                          context: OtpContext.login,
                        ),
                      );
                    case LoginFailure(:final message):
                      setState(() => _fieldError = message);
                      IpsSnackbar.showError(context, message);
                    case LoginInitial() || LoginSubmitting():
                      break;
                  }
                },
                builder: (context, state) {
                  final isSubmitting = state is LoginSubmitting;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth >= 600 ? 24 : 16,
                          vertical: IpsSpacing.xxl,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: IpsSpacing.lg),
                                IpsSecurityFrame(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const IpsScreenHeader(
                                        title: 'نقابة المبرمجين العراقيين',
                                        description:
                                            'سجّل الدخول للمتابعة إلى خدمات النقابة الرقمية',
                                      ),
                                      const SizedBox(height: IpsSpacing.xxxl),
                                      IpsPhoneField(
                                        controller: _phoneController,
                                        enabled: !isSubmitting,
                                        errorText: _fieldError,
                                        helperText:
                                            'سنرسل رمز تحقق على هذا الرقم',
                                        onChanged: (_) {
                                          if (_fieldError != null) {
                                            setState(() => _fieldError = null);
                                          }
                                        },
                                      ),
                                      const SizedBox(height: IpsSpacing.xxl),
                                      IpsPressableScale(
                                        child: IpsGoldButton(
                                          label: 'تسجيل الدخول',
                                          isLoading: isSubmitting,
                                          onPressed: () => _submit(context),
                                        ),
                                      ),
                                      const SizedBox(height: IpsSpacing.md),
                                      IpsPressableScale(
                                        child: IpsOutlinedButton(
                                          label: 'الدخول كضيف',
                                          onPressed: isSubmitting
                                              ? null
                                              : () => context.go(
                                                  AppRoutes.guestHome,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: IpsSpacing.xxxl),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
