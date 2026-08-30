import 'package:flutter/material.dart';

import 'core/utils/flavor_helper.dart';
import 'main_app.dart';

void main() {
  FlavorConfig.initialize(Flavor.ipsProd);
  runApp(const IpsApp());
}
