class NetworkConstants {
  static const String baseUrl = 'https://nxlt0nhn-3181.inc1.devtunnels.ms/';

  // static const String baseUrl = 'https://coolie.itfuturz.in/';
  // static const String baseUrl = 'https://965rz0z3-3181.inc1.devtunnels.ms/';
  static const int sendTimeout = 30000;

  /// Coolie APIs
  static const String signInCollie = 'api/users/signInCollie';
  static const String otpVerificationCollie = 'api/users/isVerifiedCollie';
  static const String sendOtpCollie = 'api/users/signIn';
  static const String getCoolieProfile = 'api/users/collieProfile';
  static const String faceDetect = 'api/users/faceLogin';
  static const String getNextBooking = 'api/users/getNextBooking';
  static const String jobOffCollie = 'api/users/jobOff';
  static const String bookingAction = 'api/users/bookingAction';
  static const String startService = 'api/users/startService';
  static const String completeService = 'api/users/completeService';
  static const String updateWeight = 'api/users/updateWeight';
  static const String logoutCollie = 'api/users/logout';
  static const String currentBookingStatus = 'api/users/currentBookingStatus';
  static const String allCompletedBookings = 'api/users/AllcompletedBookings';
  static const String registerCollie = 'api/admin/collie/registerCollie';

  /// Mukadam APIs
  static const String signInMukadam = 'api/signInMukadam';
  static const String verifyMukadamOTP = 'api/verifyMukadamOTP';
  static const String resendMukadamOTP = 'api/resendMukadamOTP';
  static const String getMukadamProfile = 'api/getMukadamProfile';
  static const String updateMukadamProfile = 'api/updateMukadamProfile';
  static const String getMukadamCurrentShift = 'api/getMukadamCurrentShift';
  static const String mukadamLogout = 'api/mukadamLogout';
  static const String mukadamJobOn = 'api/mukadamJobOn';
  static const String mukadamJobOff = 'api/mukadamJobOff';
  static const String downloadCalendarPDF = 'api/downloadCalendarPDF';
  static const String mukadamAttendance = 'api/mukadamAttendance';
  static const String approveCollieSession = 'api/approveCollieSession';
  static const String rejectCollieSession = 'api/rejectCollieSession';
}
