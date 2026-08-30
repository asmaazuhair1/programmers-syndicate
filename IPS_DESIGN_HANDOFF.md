# IPS App Redesign and Flutter Implementation Brief

## Project

Redesign the **Iraqi Programmers Syndicate (IPS)** mobile application and provide production-ready Flutter code.

The app is part of an existing multi-flavor Flutter project. Your design and code must apply only to:

- `ipsProd`
- `ipsUat`

Do not visually change MOE, MOW, DQ, or OPDC flavors.

## Product identity

- Arabic name: **نقابة المبرمجين العراقيين**
- English name: **Iraqi Programmers Syndicate**
- Primary audience: Iraqi programmers and citizens using syndicate digital services
- Main language: Arabic
- Layout direction: RTL
- Current IPS primary color: `#041428`
- Brand character: official, trustworthy, modern, technical, clear, and accessible

Use the supplied official IPS logo and app icon. Build a broader supporting palette around the brand rather than making every element dark navy.

## Goal

Create a coherent, modern redesign for the IPS experience, including both UI design and working Flutter implementation.

The result should feel like a real government/professional-services application, not a marketing landing page. Prioritize clarity, repeated use, fast scanning, accessible controls, and predictable navigation.

## Required screens and flows

Redesign all IPS-facing native screens, including:

1. Login and welcome
   - Welcome branding is integrated into the login screen; there is no separate welcome page.
   - Phone-number login
   - Primary login button
   - Outlined **الدخول كضيف** button inside the login panel
   - Registration entry
   - Forgot-password entry
   - Loading, validation, error, and keyboard states

2. OTP verification
   - Login OTP
   - Registration OTP
   - Forgot-password OTP
   - Resend timer and error states

3. Registration and KYC
   - Registration stepper
   - Personal information
   - Passport, national ID, and residence-card scanning
   - Face verification
   - KYC update flow
   - Clear progress and validation states

4. Main application shell
   - Embedded mini-app WebView
   - App bar and navigation controls
   - Loading, offline, error, and retry states
   - Guest and authenticated states

5. Notifications
   - Flat list rows separated by thin lines, not cards
   - Compact typography
   - Read/unread indicated by the notification icon
   - Unread dot positioned on the icon using the IPS primary color
   - Read notifications must not become greyed-out or visually disabled
   - Dates use English digits
   - Notification details screen

6. Checkout and cards
   - Checkout
   - Add card
   - Saved-card management
   - Payment success and failure
   - Guest-login restriction prompts

7. Supporting states
   - Empty states
   - Network errors
   - API errors
   - Loading states
   - Confirmation dialogs
   - Snackbars and validation messages

## Existing code locations

Use and update the existing implementation instead of rebuilding business logic:

- App bootstrap: `lib/main_app.dart`
- IPS entry points:
  - `lib/main_ips_prod.dart`
  - `lib/main_ips_uat.dart`
- Routing: `lib/routes/app_routes.dart`
- Theme and colors: `lib/core/app_styles/`
- Flavor branding: `lib/core/utils/flavor_helper.dart`
- Login: `lib/features/login/`
- Registration and KYC: `lib/features/registration_stepper/`
- OTP: `lib/features/otp/`
- Main WebView: `lib/features/webview/`
- Notifications: `lib/features/notifications/`
- Checkout: `lib/features/checkout/`
- Shared widgets: `lib/core/widgets/`

## Technical constraints

- Keep the existing Flutter architecture, routes, Cubits, services, APIs, and models.
- Do not rewrite authentication, payment, KYC, Firebase, freeRASP, or WebView bridge logic.
- Do not rename or remove existing public routes without coordinating the migration.
- Create IPS-specific theme tokens/components where needed; avoid scattering flavor checks through every widget.
- Reuse shared components when their behavior is common, but ensure visual changes are scoped to IPS.
- Preserve Arabic copy and RTL behavior.
- Keep `+964` visually LTR and phone input behavior unchanged.
- Preserve accessibility, safe areas, keyboard handling, scrolling, and text scaling.
- Support small phones, modern large phones, and tablets in portrait orientation.
- Avoid fixed layouts that overflow when Arabic text grows.
- Use Material/Lucide-style familiar icons rather than custom decorative SVG controls.
- Do not add nested cards or card-heavy page layouts.
- Do not change bundle IDs, signing, Firebase configuration, or release settings.

## Visual direction

- Quiet and professional operational UI
- Clear content hierarchy
- Strong Arabic typography
- Compact but comfortable spacing
- Restrained elevation and borders
- Cards only when they represent a genuinely grouped object or tool
- Full-width sections and flat lists where appropriate
- Consistent field, button, dialog, loading, and error treatments
- Meaningful motion only; avoid decorative animation

Avoid generic purple gradients, oversized marketing headings, glassmorphism, decorative blobs, and excessive rounded containers.

## Deliverables

Provide:

1. A visual design system for IPS
   - Color tokens
   - Typography scale
   - Spacing scale
   - Radius, border, elevation, and icon rules
   - Button, field, list-row, app-bar, dialog, snackbar, and loading specifications

2. Screen designs
   - Mobile portrait designs for every required screen
   - Small-phone and large-phone behavior
   - Loading, empty, validation, error, disabled, read/unread, guest, and authenticated states

3. Production-ready Flutter code
   - Complete Dart files, not partial snippets
   - Reusable IPS components and theme definitions
   - Minimal changes to existing business logic
   - Clear list of modified and added files

4. Assets
   - Exported raster assets at appropriate resolutions
   - Source design assets
   - Updated IPS Prod and UAT launcher icons if redesigned
   - No placeholder imagery

5. Verification notes
   - Commands used to run and validate the app
   - Screens tested
   - Device sizes tested
   - Any assumptions or unresolved dependencies

## Run commands

```bash
flutter pub get
flutter run --flavor ipsUat -t lib/main_ips_uat.dart
flutter run --flavor ipsProd -t lib/main_ips_prod.dart
```

For production security builds, the repository owner will provide the required signing configuration. Do not place signing hashes, credentials, keys, or secrets in design files or source code.

## Acceptance criteria

- IPS Prod and UAT share the new IPS design.
- Other flavors retain their current appearance.
- All existing flows remain functional.
- There is no separate welcome/splash page after native launch; welcome content is part of login.
- Guest login is available as an outlined primary-color button in the login panel.
- Arabic RTL layout is correct throughout.
- No clipping, overlap, or keyboard-induced empty gaps occur.
- All screens include realistic loading, error, empty, and disabled states.
- Flutter analysis passes without new errors.
- The result is ready for integration, not only a visual concept.
