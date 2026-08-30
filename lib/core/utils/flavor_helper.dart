/// Identifies which brand/flavor of the app is currently running.
///
/// Only IPS flavors are defined for now. Additional flavors (MOE, MOW, DQ,
/// OPDC) can be added here later without changing any IPS-specific code,
/// since all IPS UI branches on `Flavor.isIps` rather than a specific value.
enum Flavor {
  ipsProd,
  ipsUat;

  bool get isIps => this == ipsProd || this == ipsUat;

  bool get isProduction => this == ipsProd;
}

/// Holds the flavor selected by the running entry point (main_ips_prod.dart,
/// main_ips_uat.dart, ...). Must be set once, before [runApp].
class FlavorConfig {
  FlavorConfig._();

  static Flavor? _flavor;

  static void initialize(Flavor flavor) {
    _flavor = flavor;
  }

  static Flavor get flavor {
    final flavor = _flavor;
    assert(flavor != null, 'FlavorConfig.initialize must be called before use.');
    return flavor ?? Flavor.ipsProd;
  }
}
