import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/app_styles/ips_typography.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/ips_gold_button.dart';
import '../../../../core/widgets/ips_screen_header.dart';
import '../../../../core/widgets/ips_snackbar.dart';
import '../../../../core/widgets/ips_technical_backdrop.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/otp_context.dart';
import '../cubit/otp_cubit.dart';
import '../cubit/otp_state.dart';
import '../widgets/otp_input_group.dart';
import '../widgets/otp_segmented_input.dart';
import '../widgets/otp_verification_controls.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({
    super.key,
    required this.localPhoneNumber,
    required this.otpContext,
  });

  final String localPhoneNumber;
  final OtpContext otpContext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit(
        Injector.instance.otpRepository,
        localPhoneNumber: localPhoneNumber,
        context: otpContext,
      ),
      child: _OtpView(
        localPhoneNumber: localPhoneNumber,
        otpContext: otpContext,
      ),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView({required this.localPhoneNumber, required this.otpContext});

  final String localPhoneNumber;
  final OtpContext otpContext;

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  String _code = '';

  void _onCompleted(BuildContext context, String code) {
    context.read<OtpCubit>().submitCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IpsColors.surfaceMuted,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: IpsColors.textPrimary),
      ),
      // SizedBox.expand forces the Stack to always be exactly screen-sized,
      // instead of letting it shrink to fit the scrollable content (a
      // plain `Stack` sizes itself to its non-positioned child, which was
      // pulling the background decoration up to sit right under the form
      // instead of covering the true full screen).
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Decoration bleeds to the true screen edges, outside SafeArea.
            const Positioned.fill(child: IpsTechnicalBackdrop()),
            SafeArea(
              child: BlocConsumer<OtpCubit, OtpState>(
                listener: (context, state) {
                  if (state.status == OtpStatus.success) {
                    switch (widget.otpContext) {
                      case OtpContext.login:
                        context.go(
                          AppRoutes.registration,
                          extra: RegistrationRouteArgs(
                            initialLocalPhoneNumber: widget.localPhoneNumber,
                          ),
                        );
                      case OtpContext.registration:
                        context.go(AppRoutes.home);
                      case OtpContext.forgotPassword:
                        context.go(AppRoutes.guestHome);
                    }
                  } else if (state.status == OtpStatus.error &&
                      state.errorMessage != null) {
                    IpsSnackbar.showError(context, state.errorMessage!);
                  }
                },
                builder: (context, state) {
                  final isSubmitting = state.status == OtpStatus.submitting;
                  final hasError = state.status == OtpStatus.error;
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
                                IpsScreenHeader(
                                  title: widget.otpContext.title,
                                  description: widget.otpContext.description,
                                ),
                                const SizedBox(height: IpsSpacing.xxxl),
                                OtpInputGroup(
                                  spacing: IpsSpacing.xxxl,
                                  children: [
                                    Center(
                                      child: _PhoneNumberLine(
                                        localPhoneNumber:
                                            widget.localPhoneNumber,
                                      ),
                                    ),
                                    OtpSegmentedInput(
                                      length: 6,
                                      enabled: !isSubmitting,
                                      hasError: hasError,
                                      onChanged: (value) {
                                        setState(() => _code = value);
                                      },
                                      onCompleted: (value) =>
                                          _onCompleted(context, value),
                                    ),
                                  ],
                                ),
                                if (hasError && state.errorMessage != null) ...[
                                  const SizedBox(height: IpsSpacing.sm),
                                  Text(
                                    state.errorMessage!,
                                    style: IpsTypography.labelSmall(
                                      color: IpsColors.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                const SizedBox(height: IpsSpacing.xxl),
                                IpsGoldButton(
                                  label: 'تحقق',
                                  isLoading: isSubmitting,
                                  onPressed: _code.length == 6
                                      ? () => _onCompleted(context, _code)
                                      : null,
                                ),
                                const SizedBox(height: IpsSpacing.xl),
                                Center(
                                  child: ResendButton(
                                    canResend: state.canResend,
                                    isResending:
                                        state.status == OtpStatus.resending,
                                    secondsRemaining:
                                        state.resendSecondsRemaining,
                                    totalSeconds: 60,
                                    onResend: () =>
                                        context.read<OtpCubit>().resendCode(),
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

/// The "+964" country code plus local number, rendered as a single
/// [Text.rich] (so it still matches a plain-text finder) with the country
/// code in gold and the number in white (readable against the dark OTP
/// background), forced LTR so digit order never flips inside the RTL
/// layout.
class _PhoneNumberLine extends StatelessWidget {
  const _PhoneNumberLine({required this.localPhoneNumber});

  final String localPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '+964 ',
              style: IpsTypography.ltrDigits(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IpsColors.gold,
              ),
            ),
            TextSpan(
              text: localPhoneNumber,
              style: IpsTypography.ltrDigits(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IpsColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
