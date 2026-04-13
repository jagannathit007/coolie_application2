import '../../services/app_toasting.dart';
import '/services/notification_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:license_sahayak/routes/route_name.dart';
import '../../services/helper.dart';
import 'auth_service.dart';

class SignCtrl extends GetxController {
  final isLoading = false.obs;
  final mobileController = TextEditingController();
  late final AuthService authService;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    mobileController.text = '';
  }

  void _initializeServices() => authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : Get.put(AuthService());

  Future<void> signIn() async {
    if (mobileController.text.isEmpty) {
      warningToast("Please Enter the mobile number");
      return;
    }
    isLoading.value = true;
    try {
      String fcmToken = await notificationService.getToken() ?? "";
      String deviceId = await helper.getDeviceUniqueId();
      final response = await authService.signIn(mobileNo: mobileController.text, deviceId: deviceId, fcm: fcmToken);
      if (response != null) {
        Get.toNamed(RouteName.otpVerification, arguments: {"mobileNo": mobileController.text});
      }
    } catch (e) {
      errorToast('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}
