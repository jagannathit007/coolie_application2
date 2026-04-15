class NetworkConstants {
  // static const String baseUrl = 'https://coolie.itfuturz.in/';
  // static const String baseUrl = 'https://nxlt0nhn-3181.inc1.devtunnels.ms/';
  static const String baseUrl = 'https://965rz0z3-3181.inc1.devtunnels.ms/';
  static const int sendTimeout = 30000;

  /// Coolie APIs
  static const String signInCollie = 'api/users/signInCollie';
  static const String otpVerificationCollie = 'api/users/isVerifiedCollie';
  static const String sendOtpCollie = 'api/users/signIn';
  static const String resendOTP = 'api/users/resendOTP';
  static const String getCoolieProfile = 'api/users/collieProfile';
  static const String faceDetect = 'api/users/faceLogin';
  static const String jobOffCollie = 'api/users/jobOff';
  static const String getNextBooking = 'api/users/getNextBooking';
  static const String bookingAction = 'api/users/bookingAction';
  static const String startService = 'api/users/startService';
  static const String completeService = 'api/users/completeService';
  static const String updateWeight = 'api/users/updateWeight';
  static const String currentBookingStatus = 'api/users/currentBookingStatus';
  static const String allCompletedBookings = 'api/users/AllcompletedBookings';
  static const String logoutCollie = 'api/users/logout';

  /// Mukadam APIs
  static const String signInMukadam = 'api/users/signInMukadam';
  static const String verifyMukadamOTP = 'api/users/verifyMukadamOTP';
  static const String resendMukadamOTP = 'api/users/resendMukadamOTP';
  static const String getMukadamProfile = 'api/users/getMukadamProfile';
  static const String mukadamFaceLogin = 'api/users/mukadamFaceLogin';
  static const String mukadamJobOff = 'api/users/mukadamJobOff';
  static const String mukadamAttendance = 'api/users/mukadamAttendance';
  static const String approveCollieSession = 'api/users/approveCollieSession';
  static const String rejectCollieSession = 'api/users/rejectCollieSession';
  static const String checkStationRadius = 'api/users/checkStationRadius';
  static const String mukadamLogout = 'api/users/mukadamLogout';
  static const String colliePunchReport = '/api/admin/collie-punch-report';
}
