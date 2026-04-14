import 'dart:convert';
import 'package:get/get.dart';
import 'package:license_sahayak/api_constants/api_manager.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import '../../models/sign_in_response_model.dart';
import '../../models/user_model.dart';
import '../../routes/route_name.dart';
import '../../services/app_storage.dart';
import '../../services/app_toasting.dart';

class AuthService extends GetxService {
  Future<SignInResponseModel?> signIn({required String mobileNo, required String deviceId, required String fcm}) async {
    try {
      final result = await apiManager.post(NetworkConstants.signInCollie, data: {"mobileNo": mobileNo, "deviceId": deviceId, "fcm": fcm});
      if (result.data is Map<String, dynamic>) {
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

  Future<UserModel?> verifyOtp(Map<String, dynamic> request) async {
    try {
      final result = await apiManager.post(NetworkConstants.otpVerificationCollie, data: request);
      final responseData = result.data is String ? json.decode(result.data) : result.data;
      if (responseData['user'] == null || responseData['token'] == null) {
        errorToast(result.message);
        return null;
      }
      final userModel = UserModel.fromJson({"user": responseData['user'], "token": responseData['token']});
      return userModel;
    } catch (e) {
      errorToast("Network error occurred");
      return null;
    }
  }

  Future<void> reSendOtp(dynamic request) async {
    try {
      final response = await apiManager.post(NetworkConstants.otpVerificationCollie, data: request);
      if (response.data == null) {
        errorToast(response.message);
        return;
      }
      if (response.status != 200) {
        warningToast(response.message);
        return;
      }
      final verifyData = response.data is String ? json.decode(response.data) : response.data;
      if (verifyData["token"] == null || verifyData["user"] == null) {
        errorToast("Authentication token or user data not received");
        return;
      }
      await AppStorage.write("token", verifyData["token"]);
      await AppStorage.write("passengerID", verifyData["user"]["_id"]);
      await AppStorage.write("user", json.encode(verifyData["user"]));
      Get.toNamed(RouteName.home);
    } catch (err) {
      errorToast("Failed to resend OTP: $err");
    }
  }
}
