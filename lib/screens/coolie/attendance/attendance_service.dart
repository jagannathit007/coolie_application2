import 'package:license_sahayak/api_constants/api_manager.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:license_sahayak/services/app_toasting.dart';
import '../../../models/punch_report_model.dart';

class AttendanceService {
  Future<PunchReportData?> getPunchReport({int page = 1, int limit = 50, String collieId = '', String mukadamId = '', String startDate = '', String endDate = ''}) async {
    try {
      final response = await apiManager.post(
        NetworkConstants.colliePunchReport,
        data: {"page": page, "limit": limit, 'collieId': collieId, 'mukadamId': mukadamId, if (startDate.isNotEmpty) "startDate": startDate, if (endDate.isNotEmpty) "endDate": endDate},
      );
      if (response.status != 200 || response.data == null) {
        errorToast(response.message);
        return null;
      }
      return PunchReportData.fromJson(response.data);
    } catch (e) {
      errorToast("Error fetching punch report: $e");
      return null;
    }
  }

  Future<dynamic> createCollie(dynamic body) async {
    try {
      final response = await apiManager.post(NetworkConstants.mukadamAddCollie, data: body);
      if (response.status != 200) {
        warningToast(response.message);
        return null;
      }
      return response.data;
    } catch (err) {
      errorToast('Error create coolie: ${err.toString()}');
      return null;
    }
  }
}
