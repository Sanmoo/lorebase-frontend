// coverage:ignore-file
import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;

  Breakpoints._();
}

enum ScreenSize { mobile, tablet, desktop }

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= Breakpoints.tablet) return ScreenSize.desktop;
  if (width >= Breakpoints.mobile) return ScreenSize.tablet;
  return ScreenSize.mobile;
}
