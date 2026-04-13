import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Constants with _ColorMixin, _NumericalMixin, _ConstMixin, _LightColorMixin {
  Constants._();

  factory Constants() => instance;
  static final instance = Constants._();
}

mixin _ColorMixin {
  final primary = const Color(0xFFC60000);
  final primaryDark = const Color(0xFF9B0000);
  final primaryLight = const Color(0xFFFF4B4B);
  final secondary = const Color(0xFFF5C242);
  final secondaryCard = const Color(0xFFD1FAE5);
  final black = const Color(0xFF1E1F20);
  final white = const Color(0xFFFFFFFF);
  final scaffoldBackgroundColor = const Color(0xFFF8F8F8);
  final redSurface = const Color(0xFFFEF2F2);
  final redBorder = const Color(0xFFFEE2E2);
  final redLight = const Color(0xFFFFEBEB);
  final successToast = const Color(0xFF16A34A);
  final errorToast = const Color(0xFFD32F2F);
  final infoToast = const Color(0xFF2D87E8);
  final warningToast = const Color(0xFFF59E0B);
  final toast = const Color(0xFF474747);
  final grey100 = const Color(0xFFEDEEF1);
  final grey200 = const Color(0xFFD8DBDF);
  final grey400 = const Color(0xFF8E95A2);
  final grey500 = const Color(0xFF6B7280);
  final grey600 = const Color(0xFF666666);
  final grey700 = const Color(0xFF4A4E5A);
  final grey800 = const Color(0xFF40444C);
  final grey950 = const Color(0xFF25272C);
  final greyShade50 = const Color(0xFFFAFAFA);
  final greyShade100 = const Color(0xFFF5F5F5);
  final greyShade200 = const Color(0xFFEEEEEE);
  final greyShade300 = const Color(0xFFE0E0E0);
  final greyShade400 = const Color(0xFFE9E9E9);
  final greyShade500 = const Color(0xFFBDBDBD);
  final greyShade600 = const Color(0xFF757575);
  final greyShade700 = const Color(0xFF616161);
  final greyShade800 = const Color(0xFF424242);
  final greyShade900 = const Color(0xFF212121);
  final error = const Color(0xFFD32F2F);
  final apple = const Color(0xFF4BB543);
  final honeyDue = const Color(0xFFEDF8ED);
  final americanYellow = const Color(0xFFF28C38);
  final transparent = Colors.transparent;
  final white10 = Colors.white10;
  final white24 = Colors.white24;
  final white54 = Colors.white54;
  final white70 = Colors.white70;
}

mixin _NumericalMixin {
  final SizedBox square = const SizedBox(width: 15, height: 15);
  final EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 13);
  final EdgeInsets popupPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
}

mixin _ConstMixin {
  final developmentFlavorSrg = 'Dev';
  final productionFlavorSrg = 'Pro';
  final bool isDebug = kDebugMode == true && kReleaseMode == false && kProfileMode == false;
  final bool isAndroid = Platform.isAndroid && !Platform.isIOS;
}

mixin _LightColorMixin {
  final lightPrimary = const Color(0xFFC60000);
  final lightPrimaryDark = const Color(0xFF9B0000);
  final lightPrimaryLight = const Color(0xFFFF4B4B);
  final lightOnPrimary = const Color(0xFFFFFFFF);
  final lightPrimaryContainer = const Color(0xFFFEF2F2);
  final lightSecondary = const Color(0xFF0EA5A4);
  final lightOnSecondary = const Color(0xFFFFFFFF);
  final lightSecondaryContainer = const Color(0xFFD1FAE5);
  final lightSurface = const Color(0xFFF8F8F8);
  final lightOnSurface = const Color(0xFF1E293B);
  final lightSurfaceVariant = const Color(0xFFE2E8F0);
  final lightSurfaceTint = const Color(0xFFC60000);
  final lightError = const Color(0xFFD32F2F);
  final lightOnError = const Color(0xFFFFFFFF);
  final lightOutline = const Color(0xFF94A3B8);
  final lightOutlineVariant = const Color(0xFFE2E8F0);
  final lightInverseSurface = const Color(0xFF1E293B);
  final lightInversePrimary = const Color(0xFFFF8080);
  final tertiary = const Color(0xFFC60000);
}
