import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_styles/ips_colors.dart';
import '../../../../core/app_styles/ips_spacing.dart';
import '../../../../core/app_styles/ips_typography.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/ips_date_field.dart';
import '../../../../core/widgets/ips_dropdown_field.dart';
import '../../../../core/widgets/ips_gold_button.dart';
import '../../../../core/widgets/ips_snackbar.dart';
import '../../../../core/widgets/ips_technical_backdrop.dart';
import '../../../../core/widgets/ips_text_field.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/registration_form_data.dart';
import '../cubit/registration_cubit.dart';
import '../cubit/registration_state.dart';

/// The 18 Iraqi governorates, in a fixed display order.
const List<String> _governorates = [
  'بغداد',
  'البصرة',
  'نينوى',
  'أربيل',
  'النجف',
  'كربلاء',
  'ذي قار',
  'الأنبار',
  'ديالى',
  'كركوك',
  'بابل',
  'واسط',
  'ميسان',
  'القادسية',
  'المثنى',
  'صلاح الدين',
  'دهوك',
  'السليمانية',
];

const List<String> _genders = ['ذكر', 'أنثى'];

/// Personal-information form: step 1 of the account setup, collecting the
/// six required fields, validated and submitted through
/// [RegistrationCubit]. Only reached after a verified OTP in the login
/// flow, so the phone number ([initialLocalPhoneNumber]) is already known
/// and is submitted silently — there is no phone field on this screen.
/// On success it routes to the Home screen.
///
/// Shares the same light "security scanner" language as Welcome and OTP —
/// [IpsTechnicalBackdrop] behind the section header and fields (no card
/// wrapping them; content sits directly on the backdrop), with a real
/// [AppBar] back arrow + title replacing the former standalone navy hero
/// band, and a light sticky action bar built on [IpsGoldButton] replacing
/// the former solid-navy one.
class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key, this.initialLocalPhoneNumber});

  final String? initialLocalPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RegistrationCubit(Injector.instance.registrationRepository),
      child: _RegistrationView(
        initialLocalPhoneNumber: initialLocalPhoneNumber,
      ),
    );
  }
}

class _RegistrationView extends StatefulWidget {
  const _RegistrationView({this.initialLocalPhoneNumber});

  final String? initialLocalPhoneNumber;

  @override
  State<_RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<_RegistrationView> {
  late final _firstNameController = TextEditingController();
  late final _fatherNameController = TextEditingController();
  late final _grandfatherNameController = TextEditingController();
  late final _phoneController = TextEditingController(
    text: widget.initialLocalPhoneNumber ?? '',
  );

  String? _governorate;
  String? _gender;
  DateTime? _birthDate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _fatherNameController.dispose();
    _grandfatherNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final data = RegistrationFormData(
      firstName: _firstNameController.text,
      fatherName: _fatherNameController.text,
      grandfatherName: _grandfatherNameController.text,
      rawPhoneInput: _phoneController.text,
      governorate: _governorate,
      gender: _gender,
      birthDate: _birthDate,
    );
    context.read<RegistrationCubit>().submit(data);
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
        // Default titleSpacing (16) plus the leading icon's own inset inside
        // its 56px tap-target box reads as a wide gap between the back arrow
        // and the title. Tightened so the two sit closer together.
        titleSpacing: IpsSpacing.sm,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: IpsColors.textPrimary),
          onPressed: () => context.go(AppRoutes.welcome),
        ),
        title: Text(
          'إنشاء حساب',
          style: IpsTypography.titleLarge(color: IpsColors.textPrimary),
        ),
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned.fill(child: IpsTechnicalBackdrop()),
            SafeArea(
              child: BlocConsumer<RegistrationCubit, RegistrationState>(
                listener: (context, state) {
                  if (state.status == RegistrationStatus.success) {
                    context.go(AppRoutes.home);
                  } else if (state.status == RegistrationStatus.failure &&
                      state.errorMessage != null) {
                    IpsSnackbar.showError(context, state.errorMessage!);
                  }
                },
                builder: (context, state) {
                  final isSubmitting =
                      state.status == RegistrationStatus.submitting;
                  final errors = state.fieldErrors;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final horizontalPadding = constraints.maxWidth >= 600
                          ? 24.0
                          : 16.0;
                      return SingleChildScrollView(
                        // Top padding is intentionally tighter than the
                        // horizontal/bottom padding: the AppBar title
                        // ("إنشاء حساب") already sits directly above, so the
                        // first field should read as close to it rather than
                        // leaving a large gap under the header.
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          IpsSpacing.sm,
                          horizontalPadding,
                          IpsSpacing.xxl,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _FormFields(
                                  firstNameController: _firstNameController,
                                  fatherNameController: _fatherNameController,
                                  grandfatherNameController:
                                      _grandfatherNameController,
                                  isSubmitting: isSubmitting,
                                  errors: errors,
                                  governorate: _governorate,
                                  gender: _gender,
                                  birthDate: _birthDate,
                                  onGovernorateChanged: (value) =>
                                      setState(() => _governorate = value),
                                  onGenderChanged: (value) =>
                                      setState(() => _gender = value),
                                  onBirthDateChanged: (value) =>
                                      setState(() => _birthDate = value),
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
      bottomNavigationBar: BlocBuilder<RegistrationCubit, RegistrationState>(
        builder: (context, state) {
          final isSubmitting = state.status == RegistrationStatus.submitting;
          return _StickyActionBar(
            label: 'التالي',
            isLoading: isSubmitting,
            onPressed: () => _submit(context),
          );
        },
      ),
    );
  }
}

/// Field groups laid directly on the screen's backdrop (no section header,
/// no enclosing card). Carries no entrance motion of its own — content
/// simply appears with the rest of the screen.
class _FormFields extends StatelessWidget {
  const _FormFields({
    required this.firstNameController,
    required this.fatherNameController,
    required this.grandfatherNameController,
    required this.isSubmitting,
    required this.errors,
    required this.governorate,
    required this.gender,
    required this.birthDate,
    required this.onGovernorateChanged,
    required this.onGenderChanged,
    required this.onBirthDateChanged,
  });

  final TextEditingController firstNameController;
  final TextEditingController fatherNameController;
  final TextEditingController grandfatherNameController;
  final bool isSubmitting;
  final Map<String, String> errors;
  final String? governorate;
  final String? gender;
  final DateTime? birthDate;
  final ValueChanged<String?> onGovernorateChanged;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<DateTime?> onBirthDateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IpsTextField(
          label: 'الاسم الأول',
          controller: firstNameController,
          enabled: !isSubmitting,
          textInputAction: TextInputAction.next,
          errorText: errors[RegistrationField.firstName],
          required: true,
          prefix: const Icon(
            Icons.person_outline,
            color: IpsColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(height: IpsSpacing.lg),
        IpsTextField(
          label: 'اسم الأب',
          controller: fatherNameController,
          enabled: !isSubmitting,
          textInputAction: TextInputAction.next,
          errorText: errors[RegistrationField.fatherName],
          required: true,
          prefix: const Icon(
            Icons.person_outline,
            color: IpsColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(height: IpsSpacing.lg),
        IpsTextField(
          label: 'اسم الجد',
          controller: grandfatherNameController,
          enabled: !isSubmitting,
          textInputAction: TextInputAction.next,
          errorText: errors[RegistrationField.grandfatherName],
          required: true,
          prefix: const Icon(
            Icons.person_outline,
            color: IpsColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(height: IpsSpacing.lg),
        // المحافظة + الجنس pair side-by-side: both are short dropdowns with
        // nothing that needs full width, so pairing them breaks the
        // monotony of seven uniformly stacked full-width rows.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: IpsDropdownField<String>(
                label: 'المحافظة',
                hintText: 'اختر المحافظة',
                items: _governorates,
                itemLabel: (item) => item,
                value: governorate,
                enabled: !isSubmitting,
                errorText: errors[RegistrationField.governorate],
                onChanged: onGovernorateChanged,
                required: true,
              ),
            ),
            const SizedBox(width: IpsSpacing.md),
            Expanded(
              child: IpsDropdownField<String>(
                label: 'الجنس',
                hintText: 'اختر الجنس',
                items: _genders,
                itemLabel: (item) => item,
                value: gender,
                enabled: !isSubmitting,
                errorText: errors[RegistrationField.gender],
                onChanged: onGenderChanged,
                required: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: IpsSpacing.lg),
        IpsDateField(
          label: 'تاريخ الميلاد',
          value: birthDate,
          enabled: !isSubmitting,
          errorText: errors[RegistrationField.birthDate],
          onChanged: onBirthDateChanged,
          required: true,
        ),
      ],
    );
  }
}

/// "التالي" primary action as a light sticky bar (no side margins/rounding,
/// no top border) built directly on [IpsGoldButton] so it shares
/// the exact same button treatment as Welcome and OTP. [IpsGoldButton]'s
/// own fixed 54px height keeps it from stretching to fill the loose
/// [bottomNavigationBar] constraints, so no explicit min/max size pinning
/// is needed here.
class _StickyActionBar extends StatelessWidget {
  const _StickyActionBar({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: IpsColors.surface,
        boxShadow: [
          BoxShadow(
            color: IpsColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            IpsSpacing.lg,
            IpsSpacing.md,
            IpsSpacing.lg,
            IpsSpacing.md,
          ),
          child: IpsGoldButton(
            label: label,
            isLoading: isLoading,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
