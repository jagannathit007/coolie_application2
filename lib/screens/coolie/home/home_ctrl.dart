import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/models/user_model.dart';
import 'package:license_sahayak/routes/route_name.dart';
import 'package:license_sahayak/screens/auth/auth_service.dart';
import 'package:license_sahayak/screens/coolie/home/ui/passenger_cancelled_dialog.dart';
import 'package:license_sahayak/screens/coolie/home/ui/show_cancel_dialog.dart';
import 'package:license_sahayak/screens/coolie/home/ui/verify_booking.dart';
import 'package:license_sahayak/services/app_storage.dart';
import 'package:license_sahayak/services/app_toasting.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:license_sahayak/services/background_location_service.dart';
import 'package:license_sahayak/services/notification_service.dart';
import 'package:license_sahayak/services/socket_service.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import '../../../models/get_passenger_coolie_model.dart';
import '../../../repositories/authentication_repo.dart';

class HomeCtrl extends GetxController {
  final AuthenticationRepo authRepo = AuthenticationRepo();
  LocationService locationService = Get.find();
  final RxInt completedToday = 0.obs;
  final checkStatuss = ''.obs, bookingId = ''.obs, sessionId = ''.obs;
  final punchInTime = ''.obs;
  final isCheckedIn = false.obs, isMukadam = false.obs;
  Rx<GetPassengerCoolieModel> passengerDetails = GetPassengerCoolieModel().obs;
  final verificationCodeController = TextEditingController();
  var userProfile = Rxn<User>();
  var isLoading = false.obs, isCheckInLoading = false.obs, isRecetBookingLoading = false.obs;
  final ImagePicker _imagePicker = ImagePicker();
  final checkInStatusMessage = ''.obs, countdownTime = '00:00'.obs;
  Timer? _timer;

  final List<dynamic> _socketSubscriptions = [];
  List<Booking> recent = [];

  @override
  void onInit({bool? timer, bool? isVerify, String? action}) async {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args["bookingId"] != null) {
      bookingId.value = args["bookingId"];
    }
    if (args != null && args["timer"] != null) {
      timer = args["timer"];
    }
    await initialize(timer: timer, isVerify: isVerify, action: action);
    _setupSocketListeners();
  }

  @override
  void onClose() {
    _timer?.cancel();
    verificationCodeController.dispose();
    for (var sub in _socketSubscriptions) {
      sub.cancel();
    }
    _socketSubscriptions.clear();
    super.onClose();
  }

  void _setupSocketListeners() {
    _socketSubscriptions.add(
      socketService.onCoolieSuspended.listen((data) async {
        if (data != null && data.isNotEmpty && userProfile.value != null && data["collieId"] == userProfile.value!.id) {
          await fetchUserProfile();
        }
      }),
    );
    _socketSubscriptions.add(
      socketService.onNewBooking.listen((data) async {
        if (data != null && data.isNotEmpty && data["sessionId"] == sessionId.value) {
          bookingId.value = data["_id"] ?? data["bookingId"];
          await startCountdownTimer();
          await getPassengerData();
          await checkStatus();
        }
      }),
    );
    _socketSubscriptions.add(
      socketService.onBookingTimeout.listen((data) async {
        if (data != null && (data['_id'] == bookingId.value || data['bookingId'] == bookingId.value)) {
          stopTimer();
          passengerDetails.value = GetPassengerCoolieModel();
          bookingId.value = '';
          checkStatuss.value = '';
        }
      }),
    );
    _socketSubscriptions.add(
      socketService.onWeightConfirmed.listen((data) async {
        if (data != null && (data['_id'] == bookingId.value || data['bookingId'] == bookingId.value)) {
          await getPassengerData();
          verifyBooking(notificationAction: 'weight_confirmed');
        }
      }),
    );
    _socketSubscriptions.add(
      socketService.onWeightDisputed.listen((data) {
        if (data != null && (data['_id'] == bookingId.value || data['bookingId'] == bookingId.value)) {
          verifyBooking(notificationAction: 'weight_disputed');
        }
      }),
    );
    _socketSubscriptions.add(
      socketService.onPassengerCancelled.listen((data) async {
        if (data != null && (data['_id'] == bookingId.value || data['bookingId'] == bookingId.value)) {
          stopTimer();
          passengerDetails.value = GetPassengerCoolieModel();
          bookingId.value = '';
          checkStatuss.value = '';
          await loadRecent();
          if (Get.context != null) {
            PassengerCancelledDialog.show(Get.context!);
          }
        }
      }),
    );
    _socketSubscriptions.add(
      socketService.onCancelAllowed.listen((data) async {
        if (data != null && (data['_id'] == bookingId.value || data['bookingId'] == bookingId.value)) {
          passengerDetails.value.booking!.allowCancel = data["allowCancel"] ?? false;
        }
      }),
    );
    _socketSubscriptions.add(
      socketService.isConnected.listen((connected) async {
        if (connected && isCheckedIn.value) {
          await getPassengerData();
          await checkStatus();
        }
      }),
    );
    _socketSubscriptions.add(
      socketService.onShiftEnded.listen((data) async {
        if (data != null && data.isNotEmpty && userProfile.value != null && data["workerId"] == userProfile.value!.id) {
          await getMyActiveSession();
          await fetchUserProfile();
          await checkStatus();
        }
      }),
    );
  }

  Future<void> initialize({bool? timer, bool? isVerify, String? action}) async {
    isMukadam.value = AppStorage.read("isMukadam") ?? false;
    await getMyActiveSession();
    await fetchUserProfile();
    await getPassengerData();
    await checkStatus();
    await todayCompletedJobs();
    if (userProfile.value != null && userProfile.value!.id.isNotEmpty) {
      if (!socketService.isConnected.value) {
        await socketService.connect(userProfile.value!.id.toString());
      }
    }
    if (isVerify == true) verifyBooking(notificationAction: action);
    if (timer == true) startCountdownTimer();
  }

  Future<void> loadRecent() async {
    try {
      isRecetBookingLoading.value = true;
      final res = await authRepo.getHistory(page: 1, limit: 5);
      if (res != null) {
        final Map<String, dynamic> bookingsData = res['bookings'];
        final List<dynamic> docs = bookingsData['docs'];
        recent = docs.map((e) => Booking.fromJson(e)).toList();
      }
    } catch (_) {
    } finally {
      isRecetBookingLoading.value = false;
      update();
    }
  }

  AuthService authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : Get.put(AuthService());

  void stopTimer() {
    _timer?.cancel();
    countdownTime.value = '00:00';
  }

  Future<void> startCountdownTimer() async {
    countdownTime.value = '00:20';
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (checkStatuss.value == 'pending') {
        final booking = passengerDetails.value.booking;
        final bookedAt = DateTime.parse(booking!.updatedAt.toString());
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
          await getPassengerData();
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> getMyActiveSession() async {
    try {
      isLoading.value = true;
      final session = await authRepo.getMyActiveSession();
      if (session != null && session["sessionId"] != null && session["sessionId"] != "") {
        sessionId.value = session["sessionId"];
        if (session["punchInTime"] != null && session["punchInTime"] != "") {
          punchInTime.value = session["punchInTime"];
        }
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
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
      final shouldCheckOut = await Get.dialog<bool>(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), shape: BoxShape.circle),
                  child: Icon(Icons.logout_rounded, color: Constants.instance.primary, size: 26),
                ),
                const SizedBox(height: 16),
                Text(
                  'Confirm Check Out',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Are you sure you want to check out? This will end your duty?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8), height: 1.5),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Get.back(result: true),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Constants.instance.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Constants.instance.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 5))],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Check Out',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Get.back(result: false),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );
      if (shouldCheckOut != true) return;
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
        response["booking"]["allowCancel"] = response["allowCancel"] ?? false;
        passengerDetails.value = GetPassengerCoolieModel.fromJson(response);
        if (passengerDetails.value.booking != null) {
          if (checkStatuss.value == 'pending') {
            startCountdownTimer();
          }
        }
      } else {
        passengerDetails.value = GetPassengerCoolieModel();
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

  Future<bool> bookingOPTVerify(String? bookingId) async {
    if (bookingId == null) {
      errorToast("Booking ID not found!");
      return false;
    }
    try {
      isLoading.value = true;
      final response = await authRepo.verifyBookingOTP(bookingId, verificationCodeController.text.trim());
      if (response != null) {
        await AppStorage.write('status', response['booking']['status']);
        await initialize();
        Get.close(1);
        successToast("OTP Verified Successfully!");
        return true;
      }
      return false;
    } catch (e) {
      errorToast('Failed to verify OTP: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void verifyBooking({String? notificationAction}) {
    verificationCodeController.clear();
    verificationCodeController.clear();
    String bookingID = passengerDetails.value.booking?.id ?? "";
    double originalWeight = passengerDetails.value.booking?.pickupDetails?.weightStatus == "verified"
        ? double.tryParse(passengerDetails.value.booking?.pickupDetails?.weight.toString() ?? "0.0") ?? 0.0
        : double.tryParse(passengerDetails.value.booking?.pickupDetails?.originalWeight.toString() ?? "0.0") ?? 0.0;
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
      }
    } catch (e) {
      errorToast('Failed to verify OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestWeightUpdate(double newWeight, String? bookingId) async {
    if (bookingId == null) {
      errorToast("Booking ID not found!");
      return false;
    }
    try {
      isLoading.value = true;
      await authRepo.updateWeight({"bookingId": bookingId, "weight": newWeight});
      Get.close(1);
      return true;
    } catch (e) {
      errorToast('Failed to verify OTP: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelBooking(String bookingId, bool isBack) async {
    final reason = await showCancelBookingDialog(Get.context!);
    if (reason == null || reason.trim().isEmpty) return;
    try {
      isLoading.value = true;
      final response = await authRepo.cancelBooking(bookingId, reason);
      if (isBack == true) Get.close(1);
      if (response != null) {
        successToast('Booking canceled successfully');
        stopTimer();
        passengerDetails.value = GetPassengerCoolieModel();
        checkStatuss.value = '';
        this.bookingId.value = '';
      }
    } catch (e) {
      log("ERROR in Cancel Booking: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> logOut() async {
    try {
      isLoading.value = true;
      await authRepo.logOut(isMukadam: isMukadam.value);
      stopTimer();
      await AppStorage.clearAll();
      await notificationService.deleteToken();
      socketService.disconnect();
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
        }
      } else {
        checkStatuss.value = "";
      }
    } catch (e) {
      errorToast('Failed to load checkOut: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> todayCompletedJobs() async {
    try {
      isLoading.value = true;
      final response = await authRepo.todayCompletedJobs();
      if (response != null) {
        completedToday.value = int.tryParse(response["completedToday"].toString()) ?? 0;
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
          await getMyActiveSession();
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
