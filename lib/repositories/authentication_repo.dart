import 'package:license_sahayak/api_constants/api_manager.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:license_sahayak/models/user_model.dart';
import '../services/app_toasting.dart';

class AuthenticationRepo {
  Future<AuthenticationRepo> init() async => this;

  Future<User?> getUserProfile({required bool isMukadam}) async {
    try {
      String url = isMukadam ? NetworkConstants.getMukadamProfile : NetworkConstants.getCoolieProfile;
      final result = await apiManager.post(url);
      if (result.data is Map<String, dynamic>) {
        final responseData = result.data as Map<String, dynamic>;
        User? userModel;
        if (isMukadam && responseData['mukadam'] != null) {
          userModel = User(
            id: responseData['mukadam']?['_id'] ?? "",
            name: responseData['mukadam']?['name'] ?? "No mention",
            mobileNo: responseData['mukadam']?['mobileNo'] ?? "No mention",
            age: responseData['mukadam']?['age'] ?? "No mention",
            deviceType: 'mobile',
            emailId: responseData['mukadam']?['email'] ?? "No mention",
            gender: responseData['mukadam']?['gender'] ?? "No mention",
            buckleNumber: responseData['mukadam']?['buckleNumber'] ?? "---",
            station: responseData['mukadam']['stationId'],
            stationId: responseData['mukadam']['stationId']?['_id'] ?? '',
            address: responseData['mukadam']?['stationId']?['address'] ?? 'No mention',
            suspendedUntil: responseData['mukadam']?['suspendedUntil'] ?? '',
            image: ImageData(url: responseData['mukadam']?['image']?['url']),
            isLoggedIn: responseData['mukadam']?['isLoggedIn'] ?? false,
            isCheckedIn: responseData['mukadam']?['isCheckedIn'] ?? false,
            isSuspended: responseData['mukadam']?['isSuspended'] ?? false,
            isApprovalRequested: responseData['mukadam']?['isApprovalRequested'] ?? false,
            v: '',
          );
        } else if (responseData['user'] != null) {
          userModel = User.fromJson(responseData['user']);
        }
        return userModel;
      } else {
        return null;
      }
    } catch (e) {
      errorToast("Failed to fetch user profile");
      return null;
    }
  }

  Future<Map<String, dynamic>?> faceDetection(dynamic data, {required bool isMukadam}) async {
    try {
      String url = isMukadam ? NetworkConstants.mukadamFaceLogin : NetworkConstants.faceDetect;
      final result = await apiManager.post(url, data: data);
      if (result.status == 200) {
        final message = result.message.toString().toLowerCase();
        final hasFailureKeywords =
            message.contains('failed') ||
            message.contains('error') ||
            message.contains('below threshold') ||
            message.contains('not match') ||
            message.contains('unable') ||
            message.contains('not your shift time') ||
            message.contains('account is suspended');
        bool successByScore = true;
        if (result.data != null && result.data is Map<String, dynamic>) {
          final dataMap = result.data as Map<String, dynamic>;
          if (isMukadam) {
            dataMap['similarityScore'] = dataMap['verification']?['similarityScore'];
            dataMap['threshold'] = dataMap['verification']?['threshold'];
          }
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

  Future<dynamic> getMyActiveSession() async {
    try {
      final response = await apiManager.post(NetworkConstants.getMyActiveSession, data: {});
      if (response.status != 200) {
        warningToast(response.message);
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching Get Session: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> getPassenger() async {
    try {
      final response = await apiManager.post(NetworkConstants.getNextBooking, data: {});
      if (response.status != 200) {
        warningToast(response.message);
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching GetPassenger: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> getOff({required bool isMukadam}) async {
    try {
      String url = isMukadam ? NetworkConstants.mukadamJobOff : NetworkConstants.jobOffCollie;
      final response = await apiManager.post(url, data: {});
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
        warningToast(response.message);
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
      if (response.status != 200 || response.data == null) {
        warningToast(response.message);
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
        warningToast(response.message);
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching Complete: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> getRateCard() async {
    try {
      final response = await apiManager.post(NetworkConstants.getRateCard, data: {});
      if (response.status != 200) {
        warningToast(response.data ?? 'Failed to rate card');
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error Rate card: $err');
      return null;
    }
  }

  Future<dynamic> logOut({required bool isMukadam}) async {
    try {
      String url = isMukadam ? NetworkConstants.mukadamLogout : NetworkConstants.logoutCollie;
      final response = await apiManager.post(url, data: {});
      if (response.status != 200) {
        return null;
      }
      return true;
    } catch (err) {
      errorToast('Error fetching LogOut: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> checkStatus() async {
    try {
      final response = await apiManager.post(NetworkConstants.currentBookingStatus, data: {});
      if (response.status != 200) {
        warningToast(response.message);
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching CheckStatus: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> todayCompletedJobs() async {
    try {
      final response = await apiManager.post(NetworkConstants.todayCompletedJobs, data: {});
      if (response.status != 200) {
        warningToast(response.message);
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching Jobs: ${err.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getWorkerReviews({required String workerId, int page = 1, int limit = 10}) async {
    try {
      final response = await apiManager.post(NetworkConstants.getWorkerReviews, data: {"workerId": workerId, "page": page, "limit": limit});
      if (response.status != 200 || response.data == null) {
        warningToast(response.message);
        return null;
      }
      return response.data as Map<String, dynamic>;
    } catch (err) {
      errorToast('Error fetching worker reviews: $err');
      return null;
    }
  }

  Future<dynamic> getHistory({int page = 1, int limit = 10, String startDate = '', String endDate = ''}) async {
    try {
      final response = await apiManager.post(
        NetworkConstants.allCompletedBookings,
        data: {"page": page, "limit": limit, if (startDate.isNotEmpty) "startDate": startDate, if (endDate.isNotEmpty) "endDate": endDate},
      );
      if (response.status != 200) {
        warningToast(response.message);
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error fetching History: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> updateWeight(dynamic data) async {
    try {
      final response = await apiManager.post(NetworkConstants.updateWeight, data: data);
      if (response.status != 200) {
        warningToast(response.message);
        return null;
      }
      return true;
    } catch (err) {
      errorToast('Error fetching LogOut: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> cancelBooking(String bookingId, String reason) async {
    try {
      final response = await apiManager.post(NetworkConstants.cancelBooking, data: {"bookingId": bookingId, "reason": reason});
      if (response.status != 200 || response.data == null) {
        warningToast(response.message);
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error canceling booking: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> submitFeedback(Map<String, dynamic> data) async {
    try {
      final response = await apiManager.post(NetworkConstants.submitFeedback, data: data);
      if (response.status != 200) {
        warningToast(response.message);
        return null;
      }
      successToast("Thank you for your feedback!");
      return response.data;
    } catch (err) {
      errorToast('Error submitting feedback: ${err.toString()}');
      return null;
    }
  }
}
