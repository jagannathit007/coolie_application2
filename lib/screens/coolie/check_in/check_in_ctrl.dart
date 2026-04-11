import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../repositories/authentication_repo.dart';
import '../../../services/app_storage.dart';
import '../../../services/app_toasting.dart';

class CheckInCtrl extends GetxController {
  final coolieImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  final isLoading = RxBool(false);
  final AuthenticationRepo authenticationRepo = Get.find();

  TextEditingController mobileNumberController = TextEditingController();
  final isConfirmEnabled = false.obs, isEnable = false.obs, isCameraOpening = false.obs;
  GlobalKey<FormState>? formKey;

  @override
  void onInit() async {
    super.onInit();
    _loadMobileNumber();
    Future.delayed(const Duration(milliseconds: 300), () {
      openCameraDirectly();
    });
  }

  @override
  void onClose() {
    mobileNumberController.dispose();
    super.onClose();
  }

  void resetState() {
    coolieImage.value = null;
    mobileNumberController.clear();
    isLoading.value = false;
    isEnable.value = false;
    isCameraOpening.value = false;
    _loadMobileNumber();
  }

  void _loadMobileNumber() {
    try {
      final userMobile = (AppStorage.read("userMobile"));
      if (userMobile != null) {
        mobileNumberController.text = userMobile;
      } else {
        isEnable.value = true;
      }
    } catch (e) {
      mobileNumberController.text = '';
    }
  }

  Future<void> openCameraDirectly() async {
    try {
      isCameraOpening.value = true;
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800, imageQuality: 90);
      if (image != null) {
        coolieImage.value = File(image.path);
        update();
        if (formKey != null && formKey!.currentState != null) {
          await Future.delayed(const Duration(milliseconds: 500));
          await validateFace(formKey!);
        }
      } else {
        Get.close(1);
      }
    } catch (e) {
      errorToast('Failed to capture image: $e');
      Get.close(1);
    } finally {
      isCameraOpening.value = false;
    }
  }

  Future<void> pickCoolieImage() async {
    await openCameraDirectly();
  }

  bool get isButtonEnabled {
    return coolieImage.value != null && mobileNumberController.text.length == 10 && !isLoading.value;
  }

  Future<void> validateFace(GlobalKey<FormState> formKey) async {
    if (isEnable.value && (formKey.currentState == null || !formKey.currentState!.validate())) {
      return;
    }
    if (mobileNumberController.text.trim().length != 10) {
      errorToast('Please enter a valid 10-digit mobile number');
      return;
    }
    if (coolieImage.value == null) {
      errorToast('Please capture your photo first');
      return;
    }
    isLoading(true);
    update();
    try {
      final formData = dio.FormData.fromMap({"mobileNo": mobileNumberController.text.trim()});
      if (coolieImage.value != null) {
        formData.files.add(MapEntry('file', await dio.MultipartFile.fromFile(coolieImage.value!.path, filename: 'coolie_${DateTime.now().millisecondsSinceEpoch}.jpg')));
      }
      var result = await authenticationRepo.faceDetection(formData);
      if (result != null && result['success'] == true) {
        coolieImage.value = null;
        successToast(result['message'] ?? "Face login successful!");
        Get.back(result: true);
        update();
      } else if (result != null && result['success'] == false) {
        errorToast(result['message'] ?? "Face detection failed");
      }
    } catch (e) {
      errorToast('Failed to process request: $e');
    } finally {
      isLoading(false);
      update();
    }
  }
}
