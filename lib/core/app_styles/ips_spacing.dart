/// 4pt spacing scale used throughout IPS screens instead of ad-hoc padding
/// values. Screen-level horizontal padding should use [IpsBreakpoints]
/// helpers rather than these directly.
class IpsSpacing {
  IpsSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
}

/// Radius tokens. Flat list rows intentionally use [none].
class IpsRadius {
  IpsRadius._();

  static const double none = 0;
  static const double field = 8;
  static const double dialog = 12;
  static const double card = 18;
}

/// Width breakpoint used to widen screen padding and constrain content on
/// large phones/tablets, per the responsiveness requirements.
class IpsBreakpoints {
  IpsBreakpoints._();

  static const double large = 600;

  static double screenPadding(double width) => width >= large ? 24 : 16;

  /// Tablets/large screens get a centered, width-capped content column so
  /// text fields and buttons don't stretch edge-to-edge.
  static double maxContentWidth(double width) => width >= large ? 480 : width;
}
