import 'package:flutter/material.dart';
import 'package:license_sahayak/screens/coolie/attendance/attendance.dart';
import 'package:license_sahayak/screens/coolie/home/ui/profile.dart';
import '../screens/coolie/booking_history/booking_history.dart';
import '/routes/route_name.dart';
import 'package:get/get.dart';
import '../screens/coolie/home/home.dart';
import '../screens/auth/otp_verify/otp_verify.dart';
import '../screens/auth/sign_in.dart';
import '../screens/splash/splash.dart';

class RoutePages {
  static GetPage<dynamic> getPage({required String name, required GetPageBuilder page, List<GetMiddleware>? middlewares}) {
    return GetPage(
      name: name,
      page: page,
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      preventDuplicates: true,
      showCupertinoParallax: false,
      middlewares: middlewares ?? [],
    );
  }

  static final List<GetPage> pages = [
    getPage(name: RouteName.splash, page: () => SplashScreen()),
    getPage(name: RouteName.signIn, page: () => SignIn()),
    getPage(name: RouteName.otpVerification, page: () => OtpVerification()),
    getPage(name: RouteName.home, page: () => HomeScreen()),
    getPage(name: RouteName.profile, page: () => Profile()),
    getPage(name: RouteName.bookingHistory, page: () => BookingHistory()),
    getPage(name: RouteName.attendance, page: () => Attendance()),
  ];
}
