import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/app_styles/ips_typography.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/ips_app_bar.dart';
import '../../../../core/widgets/ips_primary_button.dart';
import '../../../../core/widgets/ips_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/otp_context.dart';
import '../cubit/otp_cubit.dart';
import '../cubit/otp_state.dart';
import '../widgets/otp_segmented_input.dart';

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
      child: _OtpView(localPhoneNumber: localPhoneNumber, otpContext: otpContext),
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
      appBar: IpsAppBar(title: widget.otpContext.title),
      body: SafeArea(
        child: BlocConsumer<OtpCubit, OtpState>(
          listener: (context, state) {
            if (state.status == OtpStatus.success) {
              context.go(AppRoutes.guestHome);
            } else if (state.status == OtpStatus.error && state.errorMessage != null) {
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
                          Text(
                            widget.otpContext.description,
                            style: IpsTypography.bodyLarge(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: IpsSpacing.sm),
                          Center(
                            child: Text(
                              '+964 ${widget.localPhoneNumber}',
                              style: IpsTypography.ltrDigits(color: IpsColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: IpsSpacing.xxxl),
                          OtpSegmentedInput(
                            length: 6,
                            enabled: !isSubmitting,
                            hasError: hasError,
                            onChanged: (value) => _code = value,
                            onCompleted: (value) => _onCompleted(context, value),
                          ),
                          if (hasError && state.errorMessage != null) ...[
                            const SizedBox(height: IpsSpacing.sm),
                            Text(
                              state.errorMessage!,
                              style: IpsTypography.labelSmall(color: IpsColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: IpsSpacing.xxl),
                          IpsPrimaryButton(
                            label: 'تأكيد',
                            isLoading: isSubmitting,
                            onPressed: _code.length == 6
                                ? () => _onCompleted(context, _code)
                                : null,
                          ),
                          const SizedBox(height: IpsSpacing.xl),
                          Center(
                            child: state.canResend
                                ? TextButton(
                                    onPressed: state.status == OtpStatus.resending
                                        ? null
                                        : () => context.read<OtpCubit>().resendCode(),
                                    child: Text(
                                      state.status == OtpStatus.resending
                                          ? 'جاري إعادة الإرسال...'
                                          : 'إعادة إرسال الرمز',
                                    ),
                                  )
                                : Text(
                                    'يمكنك إعادة إرسال الرمز خلال '
                                    '${state.resendSecondsRemaining} ثانية',
                                    style: IpsTypography.bodyMedium(),
                                  ),
                          ),
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
    );
  }
}
