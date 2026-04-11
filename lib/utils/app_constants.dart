import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Constants with _ColorMixin, _NumericalMixin, _ConstMixin, _LightColorMixin {
  Constants._();

  factory Constants() => instance;
  static final instance = Constants._();
}

mixin _ColorMixin {
  final black = const Color(0xff1E1F20);
  final white = const Color(0xffffffff);
  final appBarColor = const Color(0xFF0D47A1);
  final blueViolet = const Color(0xff8434F4);
  final magnolia = const Color(0xffF3EBFE);
  final americanYellow = const Color(0xffEFB203);
  final cosmicLatte = const Color(0xffFEF8E6);
  final apple = const Color(0xff4BB543);
  final honeyDue = const Color(0xffEDF8ED);
  final white10 = Colors.white10;
  final white12 = Colors.white12;
  final white24 = Colors.white24;
  final white30 = Colors.white30;
  final white38 = Colors.white38;
  final white54 = Colors.white54;
  final white60 = Colors.white60;
  final white70 = Colors.white70;
  final transparent = Colors.transparent;
  final redLight = const Color(0xffFEEBEB);
  final blue50 = const Color(0xffF1F5FF);
  final red10 = const Color(0x1AF13637);
  final apple10 = const Color(0x1A4BB543);
  final grey100 = const Color(0xffEDEEF1);
  final grey200 = const Color(0xffD8DBDF);
  final grey400 = const Color(0xff8E95A2);
  final grey500 = const Color(0xff6B7280);
  final grey600 = const Color(0xff666666);
  final grey700 = const Color(0xff4A4E5A);
  final grey800 = const Color(0xff40444C);
  final grey950 = const Color(0xff25272C);
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
  final blue400 = const Color(0xff78A0FF);
  final blue500 = const Color(0xff5D87E9);
  final blue600 = const Color(0xff4169C7);
  final blue800 = const Color(0xff183883);
  final jordyBlue = const Color(0xff96B6FF);
  final successToast = const Color.fromRGBO(72, 215, 97, 1);
  final errorToast = const Color.fromRGBO(255, 52, 91, 1);
  final infoToast = const Color.fromRGBO(45, 135, 232, 1);
  final warningToast = const Color.fromRGBO(255, 191, 37, 1);
  final toast = const Color(0xff474747);
  final primary = Color(0xFFC60000);
  final secondary = const Color(0xFF530B0E);
  final secondaryCard = const Color(0xFFA14044);
  final error = const Color(0xffa10d0d);
  final instagramRed = Color(0xFFFF3F3F);
  final scaffoldBackgroundColor = Color(0xFFF3F3F9);
}

mixin _NumericalMixin {
  final SizedBox square = const SizedBox(width: 15, height: 15);
  final EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 13);
  final EdgeInsets popupPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
}

mixin _ConstMixin {
  final developmentFlavorSrg = 'Dev', productionFlavorSrg = 'Pro';
  final bool isDebug = kDebugMode == true && kReleaseMode == false && kProfileMode == false;
  final bool isAndroid = Platform.isAndroid && !Platform.isIOS;
}

mixin _LightColorMixin {
  final lightPrimary = const Color.fromARGB(255, 255, 198, 198);
  final lightOnPrimary = const Color(0xff000000);
  final lightPrimaryContainer = const Color.fromARGB(255, 255, 160, 160);
  final lightOnPrimaryContainer = const Color(0xff000000);
  final lightSecondary = const Color.fromARGB(255, 255, 226, 226);
  final lightOnSecondary = const Color(0xff000000);
  final lightSecondaryContainer = const Color.fromARGB(255, 245, 176, 176);
  final lightOnSecondaryContainer = const Color(0xff000000);
  final tertiary = Color(0xFF530B0E);
  final lightTertiary = const Color(0xffFFDDAE);
  final lightOnTertiary = const Color(0xff000000);
  final lightTertiaryContainer = const Color(0xffFFCC80);
  final lightOnTertiaryContainer = const Color(0xff000000);
  final lightSurface = const Color(0xffFBFBFB);
  final lightOnSurface = const Color(0xff000000);
  final lightSurfaceVariant = const Color(0xffE0E0E0);
  final lightSurfaceTint = const Color.fromARGB(255, 255, 198, 198);
  final lightError = const Color(0xffB00020);
  final lightOnError = const Color(0xffffffff);
  final lightErrorContainer = const Color(0xffF9DEDC);
  final lightOnErrorContainer = const Color(0xff410002);
  final lightOutline = const Color(0xff737373);
  final lightOutlineVariant = const Color(0xffBFBFBF);
  final lightShadow = const Color(0xff000000);
  final lightScrim = const Color(0xff000000);
  final lightInverseSurface = const Color(0xff121212);
  final lightInversePrimary = const Color.fromARGB(255, 0, 0, 0);
}
