import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:license_sahayak/models/punch_report_model.dart';
import 'package:license_sahayak/models/user_model.dart';
import '../../../services/app_storage.dart';
import 'attendance_service.dart';

class AttendanceCtrl extends GetxController {
  final _service = AttendanceService();
  final isLoading = true.obs, isLoadingMore = false.obs, isMukadam = false.obs;
  final punchReports = <PunchReportCollie>[].obs;
  PunchReportSummary? punchSummary;
  int _punchCurrentPage = 1, _punchTotalPages = 1;

  bool get hasMorePunch => _punchCurrentPage < _punchTotalPages;

  final selectedStartDate = Rxn<DateTime>(DateTime.now()), selectedEndDate = Rxn<DateTime>(DateTime.now());

  String get startDateFormatted => selectedStartDate.value != null ? DateFormat('yyyy-MM-dd').format(selectedStartDate.value!) : '';

  String get endDateFormatted => selectedEndDate.value != null ? DateFormat('yyyy-MM-dd').format(selectedEndDate.value!) : '';

  String get startDateDisplay => selectedStartDate.value != null ? DateFormat('dd MMM yyyy').format(selectedStartDate.value!) : 'Start Date';

  String get endDateDisplay => selectedEndDate.value != null ? DateFormat('dd MMM yyyy').format(selectedEndDate.value!) : 'End Date';

  @override
  void onInit() {
    super.onInit();
    isMukadam.value = AppStorage.read("isMukadam") ?? false;
    fetchPunchReport();
  }

  Future<void> fetchPunchReport({bool reset = true}) async {
    if (reset) {
      isLoading.value = true;
      _punchCurrentPage = 1;
      punchReports.clear();
    }
    await _loadPunchPage(reset ? 1 : _punchCurrentPage + 1);
    if (reset) isLoading.value = false;
  }

  Future<void> loadMorePunch() async {
    if (!hasMorePunch || isLoadingMore.value) return;
    isLoadingMore.value = true;
    await fetchPunchReport(reset: false);
    isLoadingMore.value = false;
  }

  Future<void> _loadPunchPage(int page) async {
    final response = await AppStorage.read('user');
    final decoded = json.decode(response);
    User user = User.fromJson(decoded);
    final result = await _service.getPunchReport(
      page: page,
      collieId: isMukadam.value ? '' : user.id,
      mukadamId: isMukadam.value ? '' : '',
      startDate: startDateFormatted,
      endDate: endDateFormatted,
    );
    if (result != null) {
      punchSummary = result.summary;
      _punchCurrentPage = result.report.page;
      _punchTotalPages = result.report.totalPages;
      punchReports.addAll(result.report.docs);
    }
  }

  void clearFilters() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    fetchPunchReport();
  }

  bool get hasActiveFilter => selectedStartDate.value != null || selectedEndDate.value != null;
}
