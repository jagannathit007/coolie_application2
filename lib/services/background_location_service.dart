import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:get/get.dart';
import 'package:license_sahayak/models/user_model.dart';
import 'package:license_sahayak/screens/auth/auth_service.dart';
import 'package:license_sahayak/screens/coolie/home/home_ctrl.dart';
import 'package:license_sahayak/services/app_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService extends GetxService {
  Future<LocationService> init() async => this;

  RxBool isBackgroundLocation = false.obs;
  StreamSubscription<gl.ServiceStatus>? serviceStatusStream;

  AuthService authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : Get.put(AuthService());

  Timer? timer;

  Future<bool> locationAlwaysOnPermission() async {
    bool whenInUseLocation = false;
    var checkStatus = await Permission.locationWhenInUse.status;
    if (!checkStatus.isGranted) {
      var whenInUseStatus = await Permission.locationWhenInUse.request();
      if (whenInUseStatus.isGranted) {
        whenInUseLocation = true;
      }
    } else {
      whenInUseLocation = true;
    }
    return whenInUseLocation;
  }

  Future<void> locationEnabler() async {
    bool locationPermissions = await locationAlwaysOnPermission();
    if (locationPermissions == true) {
      bool isLocationEnabled = await gl.Geolocator.isLocationServiceEnabled();
      if (isLocationEnabled) {
        await startBackgroundLocation();
      }
      serviceStatusStream = gl.Geolocator.getServiceStatusStream()
          .handleError((error) {
            log('Geolocator Stream Error : $error');
          })
          .listen((gl.ServiceStatus status) async {
            isLocationEnabled = status == gl.ServiceStatus.enabled;
            if (isLocationEnabled) {
              await startBackgroundLocation();
            } else {
              stopBackgroundLocation();
            }
          });
    }
  }

  Future<void> startBackgroundLocation() async {
    if (timer == null && !isBackgroundLocation.value) {
      log("Background location is stared...!");
      isBackgroundLocation.value = true;
      timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        await getCurrentLocation();
      });
    }
  }

  void stopBackgroundLocation() {
    if (timer != null) {
      log("Background location is stopped...!");
      timer!.cancel();
      timer = null;
      isBackgroundLocation.value = false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await gl.Geolocator.getCurrentPosition(desiredAccuracy: gl.LocationAccuracy.high);
      final response = await AppStorage.read('user');
      final decoded = json.decode(response);
      User user = User.fromJson(decoded);
      if (response != null) {
        dynamic res = await authService.checkStationRadius({"stationId": user.stationId, "latitude": position.latitude, "longitude": position.longitude});
        if (res != null && res["withinRadius"] == false) {
          HomeCtrl homeCtrl = Get.isRegistered<HomeCtrl>() ? Get.find<HomeCtrl>() : Get.put(HomeCtrl());
          await homeCtrl.checkOut();
        }
      }
    } catch (error) {
      log(error.toString());
    }
  }
}
