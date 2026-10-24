import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const page = EdgeInsets.all(lg);
  static const form = EdgeInsets.all(xl);
  static const double contentWidth = 720;
  static const double formWidth = 640;
  static const double touchTarget = 48;
}

abstract final class AppRadii {
  static const double control = 12;
  static const double card = 16;
  static const double large = 24;
}
