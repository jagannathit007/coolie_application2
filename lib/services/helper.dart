import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Helper {
  Future<void> launchURL(String val) async {
    if (await canLaunchUrl(Uri.parse(val))) {
      await launchUrl(Uri.parse(val));
    } else {
      throw 'Could not launch $val';
    }
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (err) {
      log("makePhoneCall Error: $err");
    }
  }

  Future<String> getDeviceUniqueId() async {
    String deviceIdentifier = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceIdentifier = androidInfo.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor!;
    }
    return deviceIdentifier;
  }

  Future<dynamic> imageShow({required String uri, required BuildContext context}) {
    return showDialog(
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(2),
          title: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InteractiveViewer(
                child: Image.network(
                  uri,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? value) {
                    if (value == null) {
                      return child;
                    }
                    return Center(child: CircularProgressIndicator(value: value.expectedTotalBytes != null ? value.cumulativeBytesLoaded / value.expectedTotalBytes! : null));
                  },
                  errorBuilder: (context, error, stackTrace) => Container(),
                ),
              ),
            ),
          ),
        );
      },
      context: context,
    );
  }

  String formatDecimalHoursToTime(double decimalHours) {
    int hours = decimalHours.floor();
    int minutes = ((decimalHours - hours) * 60).round();
    if (minutes == 60) {
      hours++;
      minutes = 0;
    }
    return "${hours}h ${minutes.toString().padLeft(2, '0')}m";
  }

  String getFormattedDateTimer(String dtStr) {
    try {
      final utcTime = DateTime.parse(dtStr);
      const kolkataOffset = Duration(hours: 5, minutes: 30);
      final kolkataTime = utcTime.add(kolkataOffset);
      final now = DateTime.now().toUtc().add(kolkataOffset);
      final kolkataNow = DateTime(now.year, now.month, now.day);
      int dateDifference = kolkataNow.difference(kolkataTime).inDays;
      String dateFormat = (kolkataTime.year != kolkataNow.year)
          ? "dd MMM yyyy, h:mm a"
          : (dateDifference < 1)
          ? "h:mm a"
          : "dd MMM, h:mm a";
      String formattedDate = DateFormat(dateFormat, 'en_US').format(kolkataTime);
      return formattedDate;
    } catch (e) {
      return "---";
    }
  }

  String getFormattedTimer(String dtStr) {
    try {
      final utcTime = DateTime.parse(dtStr);
      const kolkataOffset = Duration(hours: 5, minutes: 30);
      final kolkataTime = utcTime.add(kolkataOffset);
      String dateFormat = "h:mm a";
      String formattedDate = DateFormat(dateFormat, 'en_US').format(kolkataTime);
      return formattedDate;
    } catch (e) {
      return "---";
    }
  }
}

Helper helper = Helper();
