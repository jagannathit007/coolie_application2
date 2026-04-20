import 'package:get/get.dart';
import 'package:license_sahayak/models/user_model.dart';

class SuspensionService extends GetxService {
  static SuspensionStatus checkSuspensionStatus(User? user) {
    if (user == null || user.isSuspended != true) {
      return SuspensionStatus(isSuspended: false);
    }
    if (user.suspendedUntil.isEmpty) {
      return SuspensionStatus(isSuspended: true, remainingTime: "Indefinite");
    }
    try {
      DateTime suspendedUntil = DateTime.parse(user.suspendedUntil);
      DateTime now = DateTime.now();
      if (suspendedUntil.isAfter(now)) {
        Duration remaining = suspendedUntil.difference(now);
        return SuspensionStatus(isSuspended: true, remainingDuration: remaining, remainingTime: _formatDuration(remaining), suspendedUntilDate: suspendedUntil);
      } else {
        return SuspensionStatus(isSuspended: false);
      }
    } catch (e) {
      return SuspensionStatus(isSuspended: true, remainingTime: "Invalid date");
    }
  }

  static String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return "${duration.inDays} day${duration.inDays > 1 ? 's' : ''} remaining";
    } else if (duration.inHours > 0) {
      return "${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} remaining";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} remaining";
    } else {
      return "Less than a minute remaining";
    }
  }

  static String getSuspensionMessage(User? user) {
    if (user == null) return "";
    final status = checkSuspensionStatus(user);
    if (!status.isSuspended) return "";
    if (status.remainingTime == "Indefinite") {
      return "Your account has been suspended indefinitely.";
    } else if (status.remainingTime == "Invalid date") {
      return "Your account has been suspended.";
    } else {
      return "Your account is suspended. ${status.remainingTime}";
    }
  }

  static bool canPerformAction(User? user) {
    final status = checkSuspensionStatus(user);
    return !status.isSuspended;
  }
}

class SuspensionStatus {
  final bool isSuspended;
  final Duration? remainingDuration;
  final String remainingTime;
  final DateTime? suspendedUntilDate;

  SuspensionStatus({required this.isSuspended, this.remainingDuration, this.remainingTime = "", this.suspendedUntilDate});
}
