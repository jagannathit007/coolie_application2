import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:license_sahayak/models/user_model.dart';
import 'package:license_sahayak/routes/route_name.dart';
import 'package:license_sahayak/screens/auth/auth_service.dart';
import 'package:license_sahayak/screens/coolie/home/ui/verify_booking.dart';
import 'package:license_sahayak/services/app_storage.dart';
import 'package:license_sahayak/services/app_toasting.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:license_sahayak/services/background_location_service.dart';
import '../../../models/get_passenger_coolie_model.dart';
import '../../../repositories/authentication_repo.dart';

class HomeCtrl extends GetxController {
  final AuthenticationRepo authRepo = AuthenticationRepo();
  LocationService locationService = Get.find();
  final checkStatuss = ''.obs, bookingId = ''.obs, sessionId = ''.obs;
  final isCheckedIn = false.obs, isMukadam = false.obs;
  Rx<GetPassengerCoolieModel> passengerDetails = GetPassengerCoolieModel().obs;
  final verificationCodeController = TextEditingController();
  var userProfile = Rxn<User>();
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
    isMukadam.value = AppStorage.read("isMukadam") ?? false;
    await fetchUserProfile();
    await getPassengerData();
    await checkStatus();
  }

  AuthService authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : Get.put(AuthService());

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
    try {
      isLoading.value = true;
      final profile = await authRepo.getUserProfile(isMukadam: isMukadam.value);
      if (profile != null) {
        userProfile.value = profile;
        isCheckedIn.value = userProfile.value?.isCheckedIn == true;
        await AppStorage.write('user', json.encode(profile.toJson()));
        if (isCheckedIn.value == true) onBackgroundLocationStart();
      } else {
        isCheckedIn.value = false;
      }
    } catch (e) {
      isCheckedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkOut() async {
    try {
      final status = checkStatuss.value.toLowerCase();
      if (status == 'pending' || status == 'accepted' || status == 'in-progress') {
        warningToast("Action not allowed. Current booking status is $status.");
        return;
      }
      isLoading.value = true;
      final response = await authRepo.getOff(isMukadam: isMukadam.value);
      locationService.stopBackgroundLocation();
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

  void verifyBooking({String? notificationAction}) {
    verificationCodeController.clear();
    verificationCodeController.clear();
    String bookingID = passengerDetails.value.booking?.id ?? "";
    double originalWeight = double.tryParse(passengerDetails.value.booking?.pickupDetails?.weight.toString() ?? "0.0") ?? 0.0;
    bool allowWeightUpdate = passengerDetails.value.booking?.pickupDetails?.weightStatus != "verified" && notificationAction == "weight_disputed";
    bool isWeightConfirmed = notificationAction == "weight_confirmed";
    otpDialog(
      verificationCodeController: verificationCodeController,
      bookedWeight: originalWeight,
      onVerify: () async => await bookingOPTVerify(bookingID),
      onRequestWeightUpdate: (newWeight) async => await requestWeightUpdate(newWeight, bookingID),
      allowWeightUpdate: allowWeightUpdate,
      isWeightConfirmed: isWeightConfirmed,
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
      Get.close(1);
    } catch (e) {
      errorToast('Failed to verify OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logOut() async {
    try {
      isLoading.value = true;
      await authRepo.logOut(isMukadam: isMukadam.value);
      stopTimer();
      AppStorage.clearAll();
      await Get.offAllNamed(RouteName.signIn);
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

  void onBackgroundLocationStart() async {
    bool locationPermissions = await locationService.locationAlwaysOnPermission();
    if (locationPermissions == true) {
      await locationService.locationEnabler();
    }
  }

  Future<void> performCheckIn() async {
    try {
      isCheckInLoading.value = true;
      bool locationPermissions = await locationService.locationAlwaysOnPermission();
      if (locationPermissions == true) {
        final position = await gl.Geolocator.getCurrentPosition(desiredAccuracy: gl.LocationAccuracy.high);
        final response = await AppStorage.read('user');
        final decoded = json.decode(response);
        User user = User.fromJson(decoded);
        if (response != null) {
          dynamic res = await authService.checkStationRadius({"stationId": user.stationId, "latitude": position.latitude, "longitude": position.longitude});
          if (res != null && res["withinRadius"] == false) {
            isCheckInLoading.value = false;
            showErrorDialog('Location not allowed. Move to your station before checking in.');
            return;
          }
        }
        checkInStatusMessage.value = 'Opening camera...';
        String mobileNumber = userProfile.value?.mobileNo ?? "";
        if (mobileNumber.isEmpty || mobileNumber.length != 10) {
          isCheckInLoading.value = false;
          showErrorDialog('Your mobile number is missing or incorrect. Please update it in your profile.', title: 'Invalid Mobile Number');
          return;
        }
        checkInStatusMessage.value = 'Capturing photo...';
        final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800, imageQuality: 90, preferredCameraDevice: CameraDevice.front);
        if (image == null) {
          isCheckInLoading.value = false;
          checkInStatusMessage.value = '';
          return;
        }
        checkInStatusMessage.value = 'Verifying your identity...';
        final File imageFile = File(image.path);
        final formData = dio.FormData.fromMap({"mobileNo": mobileNumber.trim(), "latitude": position.latitude, "longitude": position.longitude});
        formData.files.add(MapEntry('file', await dio.MultipartFile.fromFile(imageFile.path, filename: 'coolie_${DateTime.now().millisecondsSinceEpoch}.jpg')));
        final result = await authRepo.faceDetection(formData, isMukadam: isMukadam.value);
        if (result != null && result['success'] == true) {
          onBackgroundLocationStart();
          isCheckedIn.value = true;
          await fetchUserProfile();
          await getPassengerData();
          isCheckInLoading.value = false;
          checkInStatusMessage.value = '';
          successToast(result['message'] ?? "Check-in successful!");
        } else {
          locationService.stopBackgroundLocation();
          isCheckInLoading.value = false;
          checkInStatusMessage.value = '';
          showErrorDialog(result?['message'] ?? 'Face verification failed. Please try again.', title: 'Verification Failed');
        }
      } else {
        isCheckInLoading.value = false;
        showErrorDialog('Location permission is required to complete check-in. Please enable it in your device settings.', title: 'Permission Required');
      }
    } catch (e) {
      isCheckInLoading.value = false;
      checkInStatusMessage.value = '';
      showErrorDialog('Something went wrong: ${e.toString()}');
    } finally {
      isCheckInLoading.value = false;
    }
  }

  void showErrorDialog(String message, {String title = 'Check-in Failed'}) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 15, letterSpacing: .5, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(left: 42),
          child: Text(message, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, letterSpacing: .5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.close(1),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
