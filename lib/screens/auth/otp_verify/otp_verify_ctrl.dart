import 'dart:async';
import 'dart:convert';
import 'package:license_sahayak/routes/route_name.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../services/app_storage.dart';
import '../../../services/app_toasting.dart';
import '../../../services/helper.dart';
import '../../../services/notification_service.dart';
import '../auth_service.dart';

class OtpVerifyCtrl extends GetxController {
  final mobile = ''.obs;
  final verificationCodeController = TextEditingController();
  late final AuthService authService;
  final isLoading = false.obs, isResendEnabled = true.obs, isMukadam = false.obs;
  final countdown = 30.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    final args = Get.arguments;
    if (args != null) {
      if (args["mobileNo"] != null) mobile.value = args["mobileNo"];
      if (args["isMukadam"] != null) isMukadam.value = args["isMukadam"];
    }
    _startTimer();
  }

  void _initializeServices() => authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : Get.put(AuthService());

  void _startTimer() {
    isResendEnabled.value = false;
    countdown.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        isResendEnabled.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> verifyOtp() async {
    if (verificationCodeController.text.trim().isEmpty) {
      warningToast("Please enter OTP");
      return;
    }
    if (verificationCodeController.text.trim().length != 4) {
      warningToast("Please enter a valid 4-digit OTP");
      return;
    }
    try {
      isLoading.value = true;
      String fcmToken = await notificationService.getToken() ?? "";
      String deviceId = await helper.getDeviceUniqueId();
      final request = {"mobileNo": mobile.value, "fcm": fcmToken, "deviceId": deviceId};
      if (isMukadam.value) {
        request["otp"] = verificationCodeController.text.trim();
      } else {
        request["otpCode"] = verificationCodeController.text.trim();
      }
      final userModel = await authService.verifyOtp(request, isMukadam: isMukadam.value);
      if (userModel != null) {
        await AppStorage.write('token', userModel.token);
        await AppStorage.write('user', json.encode(userModel.toJson()));
        await AppStorage.write("isMukadam", isMukadam.value);
        successToast("OTP Verified Successfully");
        Get.offAllNamed(RouteName.home);
      }
    } catch (e) {
      errorToast("An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    try {
      final request = {"mobileNo": mobile.value};
      await authService.reSendOtp(request, isMukadam: isMukadam.value);
      successToast("OTP resent successfully");
      _startTimer();
    } catch (e) {
      errorToast("Failed to resend OTP: $e");
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    verificationCodeController.dispose();
    super.onClose();
  }
}
