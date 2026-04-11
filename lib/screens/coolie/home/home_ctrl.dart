import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:license_sahayak/models/coolie_user_profile.dart';
import 'package:license_sahayak/routes/route_name.dart';
import 'package:license_sahayak/services/app_storage.dart';
import 'package:license_sahayak/services/app_toasting.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../models/get_passenger_coolie_model.dart';
import '../../../repositories/authentication_repo.dart';
import '../../../services/customs/otp_verification.dart';
import '../../../utils/app_constants.dart';

class HomeCtrl extends GetxController {
  final AuthenticationRepo _authRepo = AuthenticationRepo();
  final checkStatuss = ''.obs, bookingId = ''.obs, sessionId = ''.obs;
  final isCheckedIn = false.obs;
  Rx<GetPassengerCoolieModel> passengerDetails = GetPassengerCoolieModel().obs;
  final verificationCodeController = TextEditingController();
  var userProfile = Rxn<CoolieUserProfile>();
  var isLoading = false.obs, isCheckInLoading = false.obs;
  final ImagePicker _imagePicker = ImagePicker();
  final checkInStatusMessage = ''.obs, elapsedTime = '00:00'.obs, countdownTime = '00:30'.obs;
  Timer? _timer;
  DateTime? bookingStartTime;
  final timerDurationInSeconds = 30.obs;

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

  void startTimer() {
    bookingStartTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (bookingStartTime != null) {
        final now = DateTime.now();
        final difference = now.difference(bookingStartTime!);
        final minutes = difference.inMinutes;
        final seconds = difference.inSeconds % 60;
        elapsedTime.value = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    bookingStartTime = null;
    elapsedTime.value = '00:00';
    countdownTime.value = '00:30';
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
          final remaining = 30 - elapsed;
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
      final profile = await _authRepo.getUserProfile();
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
      final response = await _authRepo.getOff();
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
      final response = await _authRepo.getPassenger();
      if (response != null) {
        sessionId.value = response["sessionId"].toString().isEmpty ? "" : response["sessionId"].toString();
        passengerDetails.value = GetPassengerCoolieModel.fromJson(response);
        if (passengerDetails.value.booking != null) {
          if (checkStatuss.value == 'pending') {
            startCountdownTimer();
          } else if (checkStatuss.value == 'accepted' || checkStatuss.value.toLowerCase() == 'in-progress') {
            if (bookingStartTime == null) {
              startTimer();
            }
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
      final response = await _authRepo.bookPassenger(bookingId, sessionId.toString(), isAccept);
      if (response != null) {
        if (isAccept) {
          startTimer();
        }
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
      final response = await _authRepo.verifyBookingOTP(bookingId, verificationCodeController.text.trim());
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

  void otpDialog() {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        title: Text("Enter OTP", style: GoogleFonts.poppins(fontSize: 15)),
        content: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                pinTextStyle: TextStyle(fontSize: 14),
                pinBoxOuterPadding: const EdgeInsets.symmetric(horizontal: 5),
                pinBoxColor: Colors.transparent,
                errorBorderColor: Colors.redAccent,
                hasTextBorderColor: Colors.black,
                controller: verificationCodeController,
              ),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: () async {
                  await bookingOPTVerify(passengerDetails.value.booking?.id);
                  Get.close(1);
                },
                height: 40,
                minWidth: double.infinity,
                color: Constants.instance.primary,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Constants.instance.primary),
                ),
                child: Text("Verify", style: GoogleFonts.poppins(color: Constants.instance.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> completeService(String? bookingId) async {
    if (bookingId == null) {
      errorToast("Booking ID not found!");
      return;
    }
    try {
      isLoading.value = true;
      final response = await _authRepo.completeService(bookingId);
      if (response != null) {
        successToast("Service Completed!");
        stopTimer();
        await getPassengerData();
        checkStatuss.value = '';
        this.bookingId.value = '';
        sessionId.value = '';
        Get.close(1);
      }
    } catch (e) {
      errorToast('Failed to verify OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logOut() async {
    try {
      isLoading.value = true;
      final response = await _authRepo.logOut();
      if (response != null) {
        Get.close(1);
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
      final response = await _authRepo.checkStatus();
      if (response != null) {
        checkStatuss.value = response["currentStatus"];
        if (checkStatuss.value == 'pending') {
          startCountdownTimer();
        } else if (checkStatuss.value == 'accepted' || checkStatuss.value.toLowerCase() == 'in-progress') {
          if (bookingStartTime == null) {
            startTimer();
          }
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

  void showLogoutDialog() {
    Get.defaultDialog(
      radius: 16.0,
      title: "Logout",
      titlePadding: const EdgeInsets.all(25.0),
      contentPadding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(onPressed: () => Get.close(1), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Get.close(1);
            stopTimer();
            await AppStorage.clearAll();
            Get.offAllNamed(RouteName.signIn);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }

  String formatBookingTime(String? isoTime) {
    if (isoTime == null) return "N/A";
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return DateFormat("hh:mm a, MMM dd").format(dt);
    } catch (e) {
      return "N/A";
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
      final result = await _authRepo.faceDetection(formData);
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
