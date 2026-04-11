import 'package:license_sahayak/screens/coolie/check_in/check_in_ctrl.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/text_box_widegt.dart';

class CheckIn extends StatelessWidget {
  CheckIn({super.key});

  final CheckInCtrl controller = Get.put(CheckInCtrl());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckInCtrl>(
      builder: (controller) {
        controller.formKey = _formKey;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xffF5F5F4),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.close(1),
            ),
            centerTitle: true,
            title: Text(
              "Check In",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Constants.instance.primary, Constants.instance.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Camera Status / Preview Section
                      Obx(() {
                        if (controller.isCameraOpening.value) {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                const SizedBox(height: 20),
                                Text(
                                  'Opening Camera...',
                                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }
                        if (controller.coolieImage.value != null) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 6))],
                                  gradient: LinearGradient(colors: [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                ),
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.file(controller.coolieImage.value!, width: 140, height: 140, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text('Processing your photo...', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                            ],
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 6))],
                            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(Icons.camera_alt, size: 40, color: Colors.white),
                          ),
                        );
                      }),
                      const SizedBox(height: 40),
                      Form(
                        key: _formKey,
                        child: Obx(() {
                          if (!controller.isEnable.value) {
                            return const SizedBox.shrink();
                          }
                          return TextBoxWidget(
                            enabled: controller.isEnable.value,
                            controller: controller.mobileNumberController,
                            hintText: 'Enter Mobile Number',
                            labelText: 'Mobile Number',
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            onChanged: (value) {
                              controller.update();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Mobile Number';
                              } else if (value.length < 10) {
                                return 'Please Enter Valid Number';
                              }
                              return null;
                            },
                          );
                        }),
                      ),
                      const Spacer(),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Constants.instance.primary)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Verifying your identity...',
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() {
                        if (controller.coolieImage.value != null && !controller.isLoading.value && !controller.isCameraOpening.value) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: GestureDetector(
                              onTap: () => controller.pickCoolieImage(),
                              child: Container(
                                width: double.infinity,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Constants.instance.primary, width: 2),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt, color: Constants.instance.primary, size: 22),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Retake Photo',
                                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Constants.instance.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
