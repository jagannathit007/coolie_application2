import 'dart:convert';
import 'package:get/get.dart';
import 'package:license_sahayak/api_constants/api_manager.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import '../../models/sign_in_response_model.dart';
import '../../models/user_model.dart';
import '../../services/app_toasting.dart';

class AuthService extends GetxService {
  Future<SignInResponseModel?> signIn({required String mobileNo, required String deviceId, required String fcm, required bool isMukadam}) async {
    try {
      String url = isMukadam ? NetworkConstants.signInMukadam : NetworkConstants.signInCollie;
      final result = await apiManager.post(url, data: {"mobileNo": mobileNo, "deviceId": deviceId, "fcm": fcm});
      if (result.data is Map<String, dynamic>) {
        if (isMukadam) {
          final request = {"mobileNo": mobileNo};
          await reSendOtp(request, isMukadam: isMukadam);
        }
        return SignInResponseModel.fromJson(result.data);
      } else {
        errorToast(result.message);
        return null;
      }
    } catch (e) {
      errorToast("Failed to send OTP: $e");
      return null;
    }
  }

  Future<UserModel?> verifyOtp(Map<String, dynamic> request, {required bool isMukadam}) async {
    try {
      String url = isMukadam ? NetworkConstants.verifyMukadamOTP : NetworkConstants.otpVerificationCollie;
      final result = await apiManager.post(url, data: request);
      if (result.data == null) {
        errorToast(result.message);
        return null;
      }
      final responseData = result.data is String ? json.decode(result.data) : result.data;
      if (responseData == null || responseData['token'] == null) {
        errorToast(result.message);
        return null;
      }
      final data = isMukadam ? responseData['mukadam'] : responseData['user'];
      if (data == null || responseData['token'] == null) {
        errorToast(result.message);
        return null;
      }
      UserModel userModel;
      if (isMukadam) {
        User user = User(
          id: data['_id'],
          name: data['name'],
          mobileNo: data['mobileNo'],
          age: data['age'],
          deviceType: 'mobile',
          emailId: data['email'],
          gender: data['gender'],
          buckleNumber: data['buckleNumber'],
          station: data['station'],
          stationId: data['stationId']?['_id'] ?? '',
          address: data['stationId']?['address'] ?? '',
          suspendedUntil: data['suspendedUntil'] ?? '',
          image: ImageData(url: data['image']?['url']),
          isLoggedIn: data['isLoggedIn'] ?? false,
          isCheckedIn: data['isCheckedIn'] ?? false,
          isApprovalRequested: data['isApprovalRequested'] ?? false,
          isSuspended: data['isSuspended'] ?? false,
          v: '',
        );
        userModel = UserModel(user: user, token: responseData['token']);
      } else {
        userModel = UserModel.fromJson({"user": data, "token": responseData['token']});
      }
      return userModel;
    } catch (e) {
      errorToast("Network error occurred");
      return null;
    }
  }

  Future<void> reSendOtp(dynamic request, {required bool isMukadam}) async {
    try {
      String url = isMukadam ? NetworkConstants.resendMukadamOTP : NetworkConstants.resendOTP;
      final response = await apiManager.post(url, data: request);
      if (response.data == null) {
        errorToast(response.message);
        return;
      }
      if (response.status != 200) {
        warningToast(response.message);
        return;
      }
      return;
    } catch (err) {
      errorToast("Failed to resend OTP: $err");
    }
  }

  Future<dynamic> checkStationRadius(dynamic request) async {
    try {
      final response = await apiManager.post(NetworkConstants.checkStationRadius, data: request);
      if (response.data == null) {
        errorToast(response.message);
        return;
      }
      if (response.status != 200) {
        warningToast(response.message);
        return;
      }
      return response.data;
    } catch (err) {
      errorToast("Failed to resend OTP: $err");
    }
    return;
  }
}
