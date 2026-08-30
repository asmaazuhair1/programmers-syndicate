# IPS App — Sub-project 1: Foundation, Design System, Login & OTP

Date: 2026-08-30
Status: Approved for planning

## Context

The Iraqi Programmers Syndicate (IPS) mobile app is being built from scratch.
`IPS_DESIGN_HANDOFF.md` (repo root) is the functional requirements and
implementation specification — it is **not** a visual design reference. This
spec covers the first of several sequential sub-projects: the Flutter
project scaffold, the IPS design system, and the Login/OTP flow. Later
sub-projects (each with their own spec → plan → implementation cycle) will
cover: Registration/KYC, the main WebView shell, Notifications, and
Checkout/Cards.

Only `ipsProd` and `ipsUat` flavors are built in this pass. Other flavors
(MOE, MOW, DQ, OPDC) referenced in the brief do not exist yet and are out of
scope — the flavor system is structured so they can be added later without
touching IPS code, but no other flavor is scaffolded now.

## Goals

- Stand up a working, feature-first Flutter project with `ipsProd`/`ipsUat`
  flavors, a shared bootstrap, and go_router-based navigation.
- Build the IPS design system as reusable tokens and widgets (`core/app_styles`,
  `core/widgets`), matching the brand character (official, trustworthy,
  modern, technical) with an original design not copied from the brief.
- Implement Login (phone number, guest login, registration/forgot-password
  entry points) and a reusable OTP verification screen (login, registration,
  forgot-password contexts), backed by a mocked `AuthRepository` so later
  sub-projects can swap in a real API without touching UI/Cubit code.
- Handle loading, validation, error, and keyboard states throughout.

## Non-goals (this sub-project)

- Real backend integration (mocked repository only).
- Registration/KYC screens beyond a stub "قيد التطوير" placeholder route.
- Forgot-password flow beyond routing to the shared OTP screen stub.
- WebView shell, notifications, checkout — separate sub-projects.
- Non-IPS flavors (MOE/MOW/DQ/OPDC).
- Launcher icon / app icon asset production (a simple in-app wordmark is
  built; launcher icon generation can follow once branding is finalized).

## Project structure

```
lib/
  main_ips_prod.dart        # entry point, Flavor.ipsProd
  main_ips_uat.dart         # entry point, Flavor.ipsUat
  main_app.dart              # shared bootstrap: DI, MaterialApp.router, theme, locale/RTL
  core/
    app_styles/
      ips_colors.dart
      ips_typography.dart
      ips_spacing.dart
      ips_theme.dart
    utils/
      flavor_helper.dart     # Flavor enum, current-flavor accessor
      validators.dart        # phone/OTP validators
    widgets/
      ips_primary_button.dart
      ips_outlined_button.dart
      ips_text_field.dart
      ips_app_bar.dart
      ips_snackbar.dart
      ips_loading_indicator.dart
      ips_error_state.dart
      ips_empty_state.dart
      ips_list_tile.dart      # flat row + thin divider, reused by Notifications later
    network/
      api_result.dart         # sealed Success/Failure wrapper
    di/
      injector.dart           # manual DI (no code-gen)
  routes/
    app_routes.dart           # go_router config + route name constants
  features/
    login/
      data/
        auth_repository.dart        # abstract interface
        mock_auth_repository.dart   # simulated network delay/success/error
      presentation/
        cubit/login_cubit.dart
        cubit/login_state.dart
        screens/login_screen.dart
        widgets/                    # login-specific widgets (phone field row, guest button)
    otp/
      data/
        otp_repository.dart
        mock_otp_repository.dart
      presentation/
        cubit/otp_cubit.dart
        cubit/otp_state.dart
        screens/otp_screen.dart     # parametrized by OtpContext
    registration/
      presentation/screens/registration_stub_screen.dart   # "قيد التطوير"
    forgot_password/
      presentation/screens/forgot_password_stub_screen.dart
```

State management: `flutter_bloc` Cubits with plain sealed classes for state
(no `freezed`/code-gen, to avoid `build_runner` friction in this pass).
Routing: `go_router`, route names as constants in `app_routes.dart`.
DI: manual constructor injection via a small `injector.dart` (no `get_it`
needed at this scale — keeps it simple and explicit).

## Design system

**Colors** (`IpsColors`, wired into a Material `ColorScheme`):
- `primary #041428` — app bar, primary buttons, focus rings
- `primaryContainer #0E2A45` — secondary emphasis
- `accent #1D7A6E` — muted teal, secondary CTAs/success accents
- `surface #FFFFFF`, `surfaceMuted #F5F7F9`
- `outline #D8DEE4` — borders/dividers
- `textPrimary #0B1B2B`, `textSecondary #5C6B7A`
- Semantic: `success #1D7A6E`, `warning #B7791F`, `error #C0362C`, `info #1D6FB8`

**Typography**: IBM Plex Sans Arabic via `google_fonts`, RTL default. Scale:
`displaySmall`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`,
`labelLarge`, `labelSmall`. Phone numbers and OTP digits render LTR within
RTL layout (`Directionality` override / `TextDirection.ltr` on the digit
spans) so `+964` and digits never mirror incorrectly.

**Spacing**: 4pt scale `4/8/12/16/20/24/32/40`. Screen horizontal padding
`16` on small phones, `24` on large phones/tablets via a `LayoutBuilder`
breakpoint (width ≥ 600).

**Shape/elevation**: radius `8` (fields/buttons), `12` (dialogs/sheets), `0`
for flat list rows. Elevation `0` default, `1` for app bar on scroll, `2`
for dialogs. Prefer `1px outline` borders over shadows.

**Shared widgets**: `IpsPrimaryButton`, `IpsOutlinedButton` (guest login
uses this), `IpsTextField` (built-in error/validation state), `IpsAppBar`,
`IpsSnackbar` (success/error variants), `IpsLoadingIndicator`,
`IpsErrorState`/`IpsEmptyState` (retry-capable), `IpsListTile`.

## Login flow

Single screen, no separate welcome/splash — brand mark (wordmark + short
Arabic tagline) integrated at the top of the login panel.

- `IpsTextField` for phone number: RTL label, digits entered/rendered LTR,
  fixed `+964` prefix chip inside the field (visually LTR, not editable).
- Primary button "تسجيل الدخول": disabled until phone passes validation
  (`validators.dart`); on tap, shows an inline loading state (button morphs
  to a same-size spinner, no layout shift) while `LoginCubit` calls
  `AuthRepository.requestOtp(phone)` (mocked).
- Outlined `IpsOutlinedButton` "الدخول كضيف" directly below primary button,
  in primary color — routes straight into the (future) main shell in guest
  state. For this sub-project, routes to a temporary placeholder screen
  since the WebView shell doesn't exist yet.
- Text links: "إنشاء حساب جديد" → `registration_stub_screen`,
  "نسيت كلمة المرور" → `forgot_password_stub_screen`.
- `LoginState` (sealed): `initial`, `validating`, `submitting`,
  `otpSent(phone)` (triggers navigation to OTP screen), `failure(message)`
  (shown via `IpsSnackbar`, error variant).
- Keyboard handling: `SingleChildScrollView` + `resizeToAvoidBottomInset:
  true` so the primary button is never clipped or pushed off-screen; no
  fixed heights.

## OTP flow

One reusable screen, `OtpScreen(context: OtpContext)` where
`OtpContext { login, registration, forgotPassword }` drives title copy and
the on-success destination route. 6-digit segmented input. Resend button
disabled during a 60-second countdown, re-enabled after.

`OtpState` (sealed): `initial`, `submitting`, `success`, `error(message)`
(distinct messages for wrong code vs expired code), `resent`.

## Error handling & states

Every async operation (login submit, OTP submit, OTP resend) has an
explicit loading state (no unbounded spinners over the whole screen —
button-local where possible), a failure state surfaced via `IpsSnackbar` or
inline field error text, and no silent failures. Mocked repositories
simulate: success, generic network failure, and (for OTP) wrong-code and
expired-code cases, selectable for manual testing during development.

## Testing / verification plan

- `flutter pub get`
- `flutter analyze` — must pass with no new errors
- `flutter run --flavor ipsUat -t lib/main_ips_uat.dart` — manual pass
  through: login validation states, guest login, OTP happy path, OTP wrong
  code, OTP expired/resend countdown, keyboard-open layout on a small
  simulated width (~360dp) and a large one (~430dp+).
- No automated widget/unit tests are required for this pass unless you'd
  like them added; flag if you want Cubit unit tests included in the plan.

## Assumptions

- No real IPS logo/icon supplied — an original text/geometric wordmark is
  designed as part of this pass; launcher icon generation is deferred.
- No real backend — mocked repositories stand in until API sub-project.
- Package id `com.ips.syndicate` used as placeholder Dart package name /
  applicationId, to be renamed later if a reserved identifier exists.
- Registration and forgot-password get stub screens only; full flows are
  scoped to the next sub-project.
