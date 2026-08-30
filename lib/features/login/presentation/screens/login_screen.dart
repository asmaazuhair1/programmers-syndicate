import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/ips_logo_mark.dart';
import '../../../../core/widgets/ips_outlined_button.dart';
import '../../../../core/widgets/ips_primary_button.dart';
import '../../../../core/widgets/ips_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../../../otp/domain/otp_context.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/phone_input_field.dart';

/// Login and welcome are the same screen — there is no separate splash
/// page. Brand mark sits at the top of the panel, guest login is an
/// outlined primary-color button beneath the primary CTA.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(Injector.instance.authRepository),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
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

  void _continueAsGuest(BuildContext context) {
    context.go(AppRoutes.guestHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                final width = constraints.maxWidth;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: width >= 600 ? 24 : 16,
                    vertical: IpsSpacing.xxl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: IpsSpacing.xxxl),
                          const Center(child: IpsLogoMark()),
                          const SizedBox(height: IpsSpacing.sm),
                          Text(
                            'مرحباً بك، سجّل الدخول للمتابعة إلى خدمات النقابة الرقمية',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: IpsSpacing.xxxl),
                          PhoneInputField(
                            controller: _phoneController,
                            enabled: !isSubmitting,
                            errorText: _fieldError,
                            onChanged: (_) {
                              if (_fieldError != null) {
                                setState(() => _fieldError = null);
                              }
                            },
                          ),
                          const SizedBox(height: IpsSpacing.xl),
                          IpsPrimaryButton(
                            label: 'تسجيل الدخول',
                            isLoading: isSubmitting,
                            onPressed: () => _submit(context),
                          ),
                          const SizedBox(height: IpsSpacing.md),
                          IpsOutlinedButton(
                            label: 'الدخول كضيف',
                            onPressed: isSubmitting ? null : () => _continueAsGuest(context),
                          ),
                          const SizedBox(height: IpsSpacing.xxl),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => context.push(AppRoutes.registration),
                                child: const Text('إنشاء حساب جديد'),
                              ),
                              const Text('•'),
                              TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => context.push(AppRoutes.forgotPassword),
                                child: const Text('نسيت كلمة المرور'),
                              ),
                            ],
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
