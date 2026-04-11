import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/customs/custom_rich_text.dart';
import '../../../services/customs/otp_verification.dart';
import '../../../utils/app_constants.dart';
import 'otp_verify_ctrl.dart';

class OtpVerification extends StatelessWidget {
  const OtpVerification({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpVerifyCtrl>(
      init: OtpVerifyCtrl(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F5F4),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    'OTP Verification',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Constants.instance.primary),
                  ),
                  const SizedBox(height: 10),
                  CustomRichText(
                    text1: 'Enter the 4-digit OTP sent to your Mobile Number',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  PinCodeTextField(
                    highlight: true,
                    maxLength: 4,
                    pinBoxWidth: 45,
                    pinBoxHeight: 45,
                    pinBoxRadius: 6,
                    pinBoxBorderWidth: 0.75,
                    wrapAlignment: WrapAlignment.center,
                    highlightPinBoxColor: Colors.white,
                    highlightColor: Constants.instance.primary,
                    defaultBorderColor: Colors.grey.shade500,
                    keyboardType: TextInputType.number,
                    pinTextStyle: const TextStyle(fontSize: 14),
                    pinBoxOuterPadding: const EdgeInsets.symmetric(horizontal: 5),
                    pinBoxColor: Colors.transparent,
                    errorBorderColor: Colors.redAccent,
                    hasTextBorderColor: Colors.black,
                    controller: controller.verificationCodeController,
                  ),
                  const SizedBox(height: 40),
                  Obx(
                    () => AnimatedScale(
                      scale: controller.isLoading.value ? 0.98 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                await controller.verifyOtp();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.instance.primary,
                          minimumSize: const Size(double.infinity, 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                'Verify',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => CustomRichText(
                      text1: 'Didn’t receive the OTP?  ',
                      text2: controller.countdown.value > 0 ? 'Resend OTP in ${controller.countdown.value}s' : 'Resend OTP',
                      style1: TextStyle(fontSize: 15, color: Colors.grey.shade900),
                      style2: TextStyle(fontSize: 15, color: controller.isResendEnabled.value ? Constants.instance.primary : Colors.grey.shade400),
                      onTap2: controller.isResendEnabled.value ? () => controller.resendOtp() : null,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
