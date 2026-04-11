import '../screens/coolie/booking_history/booking_history.dart';
import '/routes/route_name.dart';
import 'package:get/get.dart';
import '../screens/coolie/check_in/check_in.dart';
import '../screens/coolie/home/home.dart';
import '../screens/auth/otp verify/otp_verify.dart';
import '../screens/auth/sign_in.dart';
import '../screens/splash/splash.dart';

class RoutePages {
  static final List<GetPage> pages = [
    GetPage(name: RouteName.splash, page: () => SplashScreen()),
    GetPage(name: RouteName.home, page: () => HomeScreen()),
    GetPage(name: RouteName.bookingHistory, page: () => BookingHistory()),
    GetPage(name: RouteName.signIn, page: () => SignIn()),
    GetPage(name: RouteName.checkIn, page: () => CheckIn()),
    GetPage(name: RouteName.otpVerification, page: () => OtpVerification()),
  ];
}
