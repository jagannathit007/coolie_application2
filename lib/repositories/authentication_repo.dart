import 'package:license_sahayak/api_constants/api_manager.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import '../models/coolie_user_profile.dart';
import '../services/app_toasting.dart';

class AuthenticationRepo {
  Future<AuthenticationRepo> init() async => this;

  Future<CoolieUserProfile?> getUserProfile() async {
    try {
      final result = await apiManager.post(NetworkConstants.getCoolieProfile);
      if (result.data is Map<String, dynamic>) {
        final responseData = result.data as Map<String, dynamic>;
        Map<String, dynamic> userData;
        if (responseData['user'] != null) {
          userData = responseData['user'];
        } else if (responseData['user'] != null) {
          userData = responseData['user'];
        } else {
          return null;
        }
        return CoolieUserProfile.fromJson(userData);
      } else {
        return null;
      }
    } catch (e) {
      errorToast("Failed to fetch user profile");
      return null;
    }
  }

  Future<Map<String, dynamic>?> faceDetection(dynamic data) async {
    try {
      final result = await apiManager.post(NetworkConstants.faceDetect, data: data);
      if (result.status == 200) {
        final message = result.message.toString().toLowerCase();
        final hasFailureKeywords = message.contains('failed') || message.contains('error') || message.contains('below threshold') || message.contains('not match') || message.contains('unable');
        bool successByScore = true;
        if (result.data != null && result.data is Map<String, dynamic>) {
          final dataMap = result.data as Map<String, dynamic>;
          if (dataMap.containsKey('similarityScore') && dataMap.containsKey('threshold')) {
            double similarityScore = 0.0;
            final similarityValue = dataMap['similarityScore'];
            if (similarityValue is num) {
              similarityScore = similarityValue.toDouble();
            } else if (similarityValue is String) {
              similarityScore = double.tryParse(similarityValue) ?? 0.0;
            }
            double threshold = 0.0;
            final thresholdValue = dataMap['threshold'];
            if (thresholdValue is num) {
              threshold = thresholdValue.toDouble();
            } else if (thresholdValue is String) {
              threshold = double.tryParse(thresholdValue) ?? 0.0;
            }
            successByScore = similarityScore >= threshold;
          }
        }
        final finalSuccess = !hasFailureKeywords && successByScore;
        return {'data': result.data, 'message': result.message, 'success': finalSuccess};
      } else {
        return {'data': null, 'message': result.message, 'success': false};
      }
    } catch (err) {
      return {'data': null, 'message': err.toString(), 'success': false};
    }
  }

  Future<dynamic> getPassenger() async {
    try {
      final response = await apiManager.post(NetworkConstants.getNextBooking, data: {});
      if (response.status != 200) {
        warningToast(response.data?.message ?? 'Failed to fetch profile');
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching GetPassenger: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> getOff() async {
    try {
      final response = await apiManager.post(NetworkConstants.jobOff, data: {});
      if (response.status != 200) {
        return {'success': false, 'message': response.message, 'data': null};
      }
      return {'success': true, 'message': response.message, 'data': response.data};
    } catch (err) {
      return {'success': false, 'message': 'Error fetching GetPassenger: ${err.toString()}', 'data': null};
    }
  }

  Future<dynamic> bookPassenger(String bookingId, String sessionId, bool isAccept) async {
    try {
      final response = await apiManager.post(NetworkConstants.bookingAction, data: {"bookingId": bookingId, "sessionId": sessionId, "action": isAccept ? "accept" : "reject"});
      if (response.status != 200) {
        warningToast(response.data?.message ?? 'Failed to fetch bookings');
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching BookPassenger: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> verifyBookingOTP(String bookingId, String otp) async {
    try {
      final response = await apiManager.post(NetworkConstants.startService, data: {"bookingId": bookingId, "otp": otp});
      if (response.status != 200) {
        warningToast(response.data?.message ?? 'Failed to fetch OTP');
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching OTP: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> completeService(String bookingId) async {
    try {
      final response = await apiManager.post(NetworkConstants.completeService, data: {"bookingId": bookingId});
      if (response.status != 200) {
        warningToast(response.data?.message ?? 'Failed to fetch OTP');
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching Complete: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> logOut() async {
    try {
      final response = await apiManager.post(NetworkConstants.logout, data: {});
      if (response.status != 200) {
        warningToast(response.data?.message ?? 'Failed to fetch OTP');
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching LogOut: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> checkStatus() async {
    try {
      final response = await apiManager.post(NetworkConstants.currentBookingStatus, data: {});
      if (response.status != 200) {
        warningToast(response.data?.message ?? 'Failed to fetch OTP');
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching CheckStatus: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> getHistory({int page = 1, int limit = 10}) async {
    try {
      final response = await apiManager.post(NetworkConstants.allcompletedBookings, data: {"page": page, "limit": limit});
      if (response.status != 200) {
        warningToast(response.data?.message ?? 'Failed to fetch history');
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching History: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> registerCoolie(dynamic data) async {
    try {
      final response = await apiManager.post(NetworkConstants.registerCollie, data: data);
      if (response.status != 200) {
        warningToast(response.data?.message ?? 'Failed to fetch profile');
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching History: ${err.toString()}');
      return null;
    }
  }
}
