/// Which flow the shared OTP screen was launched from. Drives title copy
/// and the on-success destination — the screen and Cubit stay identical.
enum OtpContext {
  login,
  registration,
  forgotPassword;

  String get title => switch (this) {
        OtpContext.login => 'تأكيد رقم الهاتف',
        OtpContext.registration => 'تأكيد إنشاء الحساب',
        OtpContext.forgotPassword => 'تأكيد استعادة كلمة المرور',
      };

  String get description => switch (this) {
        OtpContext.login => 'أدخل رمز التحقق المرسل إلى رقم هاتفك لتسجيل الدخول',
        OtpContext.registration => 'أدخل رمز التحقق المرسل إلى رقم هاتفك لإكمال إنشاء الحساب',
        OtpContext.forgotPassword => 'أدخل رمز التحقق المرسل إلى رقم هاتفك لاستعادة كلمة المرور',
      };
}
