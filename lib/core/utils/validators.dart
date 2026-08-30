/// Validation helpers shared across features. Kept flavor-agnostic and free
/// of widget/UI concerns so they can be unit tested and reused from any
/// Cubit.
class Validators {
  Validators._();

  /// Iraqi mobile numbers are 10 digits starting with 7 once the leading 0
  /// is stripped (e.g. 0781 234 5678 -> 7812345678), dialed as +964 7XXXXXXXXX.
  static final RegExp _iraqiLocalNumber = RegExp(r'^7\d{9}$');

  /// Returns null when [rawInput] is a valid Iraqi phone number (with or
  /// without a leading 0), otherwise an Arabic error message.
  static String? phoneNumber(String? rawInput) {
    final digitsOnly = (rawInput ?? '').replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    final normalized = digitsOnly.startsWith('0')
        ? digitsOnly.substring(1)
        : digitsOnly;
    if (!_iraqiLocalNumber.hasMatch(normalized)) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  /// Normalizes user input into the local 7XXXXXXXXX form used for the
  /// +964 prefix, stripping any leading zero or non-digit characters.
  static String normalizePhoneNumber(String rawInput) {
    final digitsOnly = rawInput.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.startsWith('0') ? digitsOnly.substring(1) : digitsOnly;
  }

  static String? otpCode(String? code, {int length = 6}) {
    if (code == null || code.length != length) {
      return 'الرجاء إدخال رمز التحقق كاملاً';
    }
    if (!RegExp(r'^\d+$').hasMatch(code)) {
      return 'رمز التحقق يجب أن يتكون من أرقام فقط';
    }
    return null;
  }
}
