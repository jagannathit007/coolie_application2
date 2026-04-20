import 'package:flutter_offline/flutter_offline.dart';
import 'package:license_sahayak/firebase_options.dart';
import 'package:license_sahayak/repositories/authentication_repo.dart';
import 'package:license_sahayak/routes/route_name.dart';
import 'package:license_sahayak/routes/route_pages.dart';
import 'package:license_sahayak/screens/coolie/home/home_ctrl.dart';
import 'package:license_sahayak/screens/no_internet.dart';
import 'package:license_sahayak/services/app_storage.dart';
import 'package:license_sahayak/services/background_location_service.dart';
import 'package:license_sahayak/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'utils/app_config.dart';
import 'utils/theme_constants.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await loadRepositories();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    Firebase.app();
  }
  await notificationService.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
  terminatedNotification();
  runApp(const MyApp());
}

String? lastHandledMessageId;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.messageId != null && message.messageId != lastHandledMessageId) {
    lastHandledMessageId = message.messageId;
    await notificationService.init();
    notificationService.showRemoteNotificationAndroid(message, false);
  }
}

void terminatedNotification() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null && initialMessage.messageId != lastHandledMessageId) {
    lastHandledMessageId = initialMessage.messageId;
    notificationService.showRemoteNotificationAndroid(initialMessage, true);
    _handleNotificationClick(initialMessage);
  }
}

void _handleNotificationClick(RemoteMessage message) async {
  if (message.messageId != null && message.messageId == lastHandledMessageId) {
    return;
  }
  lastHandledMessageId = message.messageId;
  final String token = AppStorage.read("token") ?? "";
  if (token.isEmpty) {
    return;
  }
  String? bookingId = message.data["_id"] ?? message.data["bookingId"];
  String? action = message.data["action"];
  if (action == "account_suspended" || action == "account_unsuspended") {
    await Future.delayed(const Duration(milliseconds: 500));
    if (Get.isRegistered<HomeCtrl>()) {
      final homeCtrl = Get.find<HomeCtrl>();
      await homeCtrl.fetchUserProfile();
    }
  }
  if (action == "cancelled_by_passenger") {
    await Future.delayed(const Duration(milliseconds: 500));
    if (Get.isRegistered<HomeCtrl>()) {
      final homeCtrl = Get.find<HomeCtrl>();
      homeCtrl.onInit();
    }
    return;
  }
  if (bookingId != null) {
    await Future.delayed(const Duration(milliseconds: 500));
    if (action == "weight_confirmed" || action == "weight_disputed") {
      if (Get.isRegistered<HomeCtrl>()) {
        final homeCtrl = Get.find<HomeCtrl>();
        homeCtrl.onInit(isVerify: true, action: action);
      }
    } else {
      if (Get.isRegistered<HomeCtrl>()) {
        final homeCtrl = Get.find<HomeCtrl>();
        homeCtrl.bookingId.value = bookingId;
        homeCtrl.onInit(timer: true);
      } else {
        Get.toNamed(RouteName.home, arguments: {"bookingId": bookingId, "timer": true});
      }
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: GetMaterialApp(
        builder: (BuildContext context, widget) {
          return OfflineBuilder(
            connectivityBuilder: (BuildContext context, List<ConnectivityResult> connectivity, Widget child) {
              if (connectivity.contains(ConnectivityResult.none)) {
                return const NoInternet();
              } else {
                return child;
              }
            },
            builder: (BuildContext context) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: widget!,
              );
            },
          );
        },
        title: AppConfig.appName,
        initialRoute: RouteName.splash,
        getPages: RoutePages.pages,
        defaultTransition: Transition.rightToLeftWithFade,
        debugShowCheckedModeBanner: false,
        theme: defaultTheme,
      ),
    );
  }
}

Future<void> loadRepositories() async {
  await Get.putAsync(() => AuthenticationRepo().init());
  await Get.putAsync(() => LocationService().init());
}
