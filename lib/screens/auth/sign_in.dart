import 'package:license_sahayak/screens/auth/sign_ctrl.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/text_box_widegt.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignCtrl());
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF5F5F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    child: Image.asset("assets/logo.png", height: 70, width: 70),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Coolie",
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sign in to continue",
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[800], fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 35),
                  TextBoxWidget(
                    controller: controller.mobileController,
                    maxLength: 10,
                    hintText: 'Enter Mobile Number',
                    prefixIcon: Icon(Icons.phone, color: Constants.instance.primary),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Mobile Number';
                      }
                      if (!value.isPhoneNumber) {
                        return 'Invalid Number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => AnimatedScale(
                      scale: controller.isLoading.value ? 0.98 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                await controller.signIn();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.instance.primary,
                          minimumSize: Size(double.infinity, 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                "Sign In",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
