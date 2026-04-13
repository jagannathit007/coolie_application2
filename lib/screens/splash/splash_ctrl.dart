import '/services/app_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import '../../routes/route_name.dart';

class SplashCtrl extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation, scaleAnimation, slideAnimation;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );
    slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    animationController.forward();
    _navigateHome();
  }

  void _navigateHome() async {
    await Future.delayed(const Duration(seconds: 3));
    final String token = AppStorage.read("token") ?? "";
    if (token.isNotEmpty) {
      Get.offAllNamed(RouteName.home);
    } else {
      Get.offAllNamed(RouteName.signIn);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
