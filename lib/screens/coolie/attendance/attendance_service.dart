import 'package:license_sahayak/api_constants/api_manager.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:license_sahayak/services/app_toasting.dart';
import '../../../models/attendance_model.dart';

class AttendanceService {
  Future<AttendanceResponseModel?> getAttendance({int page = 1, int limit = 50, String startDate = '', String endDate = '', String collieId = ''}) async {
    try {
      final response = await apiManager.post(
        NetworkConstants.mukadamAttendance,
        data: {"page": page, "limit": limit, if (startDate.isNotEmpty) "startDate": startDate, if (endDate.isNotEmpty) "endDate": endDate, if (collieId.isNotEmpty) "collieId": collieId},
      );
      if (response.status != 200 || response.data == null) {
        errorToast(response.message);
        return null;
      }
      return AttendanceResponseModel.fromJson(response.data);
    } catch (e) {
      errorToast("Error fetching attendance: $e");
      return null;
    }
  }

  Future<bool> approveSession(String sessionId) async {
    try {
      final response = await apiManager.post(NetworkConstants.approveCollieSession, data: {"sessionId": sessionId});
      if (response.status == 200) {
        successToast(response.message);
        return true;
      }
      errorToast(response.message);
      return false;
    } catch (e) {
      errorToast("Error approving session: $e");
      return false;
    }
  }

  Future<bool> rejectSession(String sessionId, {String reason = ''}) async {
    try {
      final response = await apiManager.post(NetworkConstants.rejectCollieSession, data: {"sessionId": sessionId, if (reason.isNotEmpty) "reason": reason});
      if (response.status == 200) {
        successToast(response.message);
        return true;
      }
      errorToast(response.message);
      return false;
    } catch (e) {
      errorToast("Error rejecting session: $e");
      return false;
    }
  }
}
