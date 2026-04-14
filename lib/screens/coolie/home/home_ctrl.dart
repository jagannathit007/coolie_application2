import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:license_sahayak/models/coolie_user_profile.dart';
import 'package:license_sahayak/routes/route_name.dart';
import 'package:license_sahayak/screens/coolie/home/ui/verify_booking.dart';
import 'package:license_sahayak/services/app_storage.dart';
import 'package:license_sahayak/services/app_toasting.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/get_passenger_coolie_model.dart';
import '../../../repositories/authentication_repo.dart';

class HomeCtrl extends GetxController {
  final AuthenticationRepo authRepo = AuthenticationRepo();
  final checkStatuss = ''.obs, bookingId = ''.obs, sessionId = ''.obs;
  final isCheckedIn = false.obs;
  Rx<GetPassengerCoolieModel> passengerDetails = GetPassengerCoolieModel().obs;
  final verificationCodeController = TextEditingController();
  var userProfile = Rxn<CoolieUserProfile>();
  var isLoading = false.obs, isCheckInLoading = false.obs;
  final ImagePicker _imagePicker = ImagePicker();
  final checkInStatusMessage = ''.obs, countdownTime = '00:20'.obs;
  Timer? _timer;
  DateTime? bookingStartTime;

  @override
  void onInit() async {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args["bookingId"] != null) {
      bookingId.value = args["bookingId"];
    }
    await initialize();
  }

  @override
  void onClose() {
    _timer?.cancel();
    verificationCodeController.dispose();
    super.onClose();
  }

  Future<void> initialize() async {
    await fetchUserProfile();
    await getPassengerData();
    await checkStatus();
  }

  void stopTimer() {
    _timer?.cancel();
    bookingStartTime = null;
    countdownTime.value = '00:20';
  }

  void startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final booking = passengerDetails.value.booking;
      if (booking?.timestamp?.bookedAt != null && checkStatuss.value == 'pending') {
        try {
          final bookedAt = DateTime.parse(booking!.timestamp!.bookedAt.toString());
          final now = DateTime.now();
          final elapsed = now.difference(bookedAt).inSeconds;
          final remaining = 20 - elapsed;
          if (remaining > 0) {
            final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
            final seconds = (remaining % 60).toString().padLeft(2, '0');
            countdownTime.value = '$minutes:$seconds';
          } else {
            countdownTime.value = '00:00';
            timer.cancel();
            _autoDeclineRequest();
          }
        } catch (e) {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _autoDeclineRequest() {
    final booking = passengerDetails.value.booking;
    if (booking != null && checkStatuss.value == 'pending') {
      bookPassenger(booking.id.toString(), false);
    }
  }

  String getTimerDisplay() {
    if (bookingStartTime == null) {
      return '00:00';
    }
    final now = DateTime.now();
    final difference = now.difference(bookingStartTime!);
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final profile = await authRepo.getUserProfile();
      if (profile != null) {
        userProfile.value = profile;
        isCheckedIn.value = userProfile.value?.isLoggedIn == true;
      } else {
        isCheckedIn.value = false;
      }
    } catch (e) {
      isCheckedIn.value = false;
    }
    isLoading.value = false;
  }

  Future<void> checkOut() async {
    isLoading.value = true;
    try {
      final response = await authRepo.getOff();
      if (response != null && response['success'] == true) {
        isCheckedIn.value = false;
        stopTimer();
        await fetchUserProfile();
        await getPassengerData();
        successToast(response['message'] ?? "Checked out successfully!");
      } else if (response != null && response['success'] == false) {
        errorToast(response['message'] ?? "Failed to check out");
      }
    } catch (e) {
      errorToast('Failed to check out: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPassengerData() async {
    try {
      isLoading.value = true;
      final response = await authRepo.getPassenger();
      if (response != null) {
        sessionId.value = response["sessionId"].toString().isEmpty ? "" : response["sessionId"].toString();
        passengerDetails.value = GetPassengerCoolieModel.fromJson(response);
        if (passengerDetails.value.booking != null) {
          if (checkStatuss.value == 'pending') {
            startCountdownTimer();
          } else {
            stopTimer();
          }
        }
      } else {
        sessionId.value = "";
        passengerDetails.value = GetPassengerCoolieModel();
        stopTimer();
      }
    } catch (e) {
      log("Failed to load Passenger: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bookPassenger(String bookingId, bool isAccept) async {
    try {
      isLoading.value = true;
      final response = await authRepo.bookPassenger(bookingId, sessionId.toString(), isAccept);
      if (response != null) {
        await initialize();
      }
    } catch (e) {
      errorToast('Failed to load bookPassenger: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bookingOPTVerify(String? bookingId) async {
    if (bookingId == null) {
      errorToast("Booking ID not found!");
      return;
    }
    try {
      isLoading.value = true;
      final response = await authRepo.verifyBookingOTP(bookingId, verificationCodeController.text.trim());
      if (response != null) {
        await AppStorage.write('status', response['booking']['status']);
        await initialize();
        Get.close(1);
        successToast("OTP Verified Successfully!");
      }
    } catch (e) {
      errorToast('Failed to verify OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void verifyBooking() {
    otpDialog(
      verificationCodeController: verificationCodeController,
      bookedWeight: double.tryParse(passengerDetails.value.booking?.pickupDetails?.weight.toString() ?? "0.0") ?? 0.0,
      onVerify: () async => await bookingOPTVerify(passengerDetails.value.booking?.id),
      onRequestWeightUpdate: (newWeight) async => await requestWeightUpdate(newWeight, passengerDetails.value.booking?.id),
    );
  }

  Future<void> completeService(String? bookingId) async {
    if (bookingId == null) {
      errorToast("Booking ID not found!");
      return;
    }
    try {
      isLoading.value = true;
      final response = await authRepo.completeService(bookingId);
      if (response != null) {
        successToast("Service Completed!");
        stopTimer();
        await getPassengerData();
        checkStatuss.value = '';
        this.bookingId.value = '';
        sessionId.value = '';
      }
    } catch (e) {
      errorToast('Failed to verify OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestWeightUpdate(double newWeight, String? bookingId) async {
    if (bookingId == null) {
      errorToast("Booking ID not found!");
      return;
    }
    try {
      isLoading.value = true;
      await authRepo.updateWeight({"bookingId": bookingId, "weight": newWeight});
    } catch (e) {
      errorToast('Failed to verify OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logOut() async {
    try {
      isLoading.value = true;
      final response = await authRepo.logOut();
      if (response != null) {
        stopTimer();
        AppStorage.clearAll();
        Get.offAllNamed(RouteName.signIn);
      }
    } catch (e) {
      errorToast('Failed to load LogOut: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkStatus() async {
    try {
      isLoading.value = true;
      final response = await authRepo.checkStatus();
      if (response != null) {
        checkStatuss.value = response["currentStatus"];
        if (checkStatuss.value == 'pending') {
          startCountdownTimer();
        } else {
          stopTimer();
        }
      } else {
        checkStatuss.value = "";
        stopTimer();
      }
    } catch (e) {
      errorToast('Failed to load checkOut: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performCheckIn() async {
    try {
      isCheckInLoading.value = true;
      checkInStatusMessage.value = 'Opening camera...';
      String mobileNumber = '';
      try {
        final userMobile = AppStorage.read("userMobile");
        if (userMobile != null) {
          mobileNumber = userMobile.toString();
        }
      } catch (e) {
        log("Error loading mobile number: $e");
      }
      if (mobileNumber.isEmpty || mobileNumber.length != 10) {
        isCheckInLoading.value = false;
        errorToast('Please ensure your mobile number is set correctly');
        return;
      }
      checkInStatusMessage.value = 'Capturing photo...';
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800, imageQuality: 90);
      if (image == null) {
        isCheckInLoading.value = false;
        checkInStatusMessage.value = '';
        return;
      }
      checkInStatusMessage.value = 'Verifying your identity...';
      await Future.delayed(const Duration(milliseconds: 300));
      final File imageFile = File(image.path);
      final formData = dio.FormData.fromMap({"mobileNo": mobileNumber.trim()});
      formData.files.add(MapEntry('file', await dio.MultipartFile.fromFile(imageFile.path, filename: 'coolie_${DateTime.now().millisecondsSinceEpoch}.jpg')));
      final result = await authRepo.faceDetection(formData);
      if (result != null && result['success'] == true) {
        isCheckedIn.value = true;
        await fetchUserProfile();
        await getPassengerData();
        isCheckInLoading.value = false;
        checkInStatusMessage.value = '';
        successToast(result['message'] ?? "Check-in successful!");
      } else {
        isCheckInLoading.value = false;
        checkInStatusMessage.value = '';
        final errorMessage = result?['message'] ?? "Face verification failed. Please try again.";
        errorToast(errorMessage);
      }
    } catch (e) {
      isCheckInLoading.value = false;
      checkInStatusMessage.value = '';
      errorToast('Failed to check in: ${e.toString()}');
    }
  }
}
