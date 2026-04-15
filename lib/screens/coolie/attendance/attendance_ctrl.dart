import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:license_sahayak/models/punch_report_model.dart';
import '../../../models/attendance_model.dart';
import 'attendance_service.dart';

class AttendanceCtrl extends GetxController {
  final _service = AttendanceService();
  final selectedTabIndex = 0.obs;
  final isLoading = true.obs, isLoadingMore = false.obs;
  final isApproving = ''.obs, isRejecting = ''.obs;
  final records = <AttendanceRecord>[].obs;
  MukadamInfo? mukadamInfo;
  final summary = Rxn<AttendanceSummary>();
  int _currentPage = 1, _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  final isLoadingPunchReport = true.obs, isLoadingMorePunch = false.obs;
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
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    isLoading.value = true;
    _currentPage = 1;
    records.clear();
    await _loadPage(1);
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore.value) return;
    isLoadingMore.value = true;
    await _loadPage(_currentPage + 1);
    isLoadingMore.value = false;
  }

  Future<void> _loadPage(int page) async {
    final result = await _service.getAttendance(page: page, startDate: startDateFormatted, endDate: endDateFormatted);
    if (result != null) {
      mukadamInfo = result.mukadamInfo;
      summary.value = result.summary;
      _currentPage = result.attendance.page;
      _totalPages = result.attendance.totalPages;
      records.addAll(result.attendance.docs);
    }
  }

  Future<void> approveSession(String sessionId) async {
    isApproving.value = sessionId;
    final ok = await _service.approveSession(sessionId);
    if (ok) _updateRecordApproval(sessionId);
    isApproving.value = '';
  }

  Future<void> rejectSession(String sessionId) async {
    isRejecting.value = sessionId;
    final ok = await _service.rejectSession(sessionId);
    if (ok) _updateRecordApproval(sessionId);
    isRejecting.value = '';
  }

  void _updateRecordApproval(String sessionId) => records.removeWhere((r) => r.sessionId == sessionId);

  Future<void> fetchPunchReport({bool reset = true}) async {
    if (reset) {
      isLoadingPunchReport.value = true;
      _punchCurrentPage = 1;
      punchReports.clear();
    }
    await _loadPunchPage(reset ? 1 : _punchCurrentPage + 1);
    if (reset) isLoadingPunchReport.value = false;
  }

  Future<void> loadMorePunch() async {
    if (!hasMorePunch || isLoadingMorePunch.value) return;
    isLoadingMorePunch.value = true;
    await fetchPunchReport(reset: false);
    isLoadingMorePunch.value = false;
  }

  Future<void> _loadPunchPage(int page) async {
    final result = await _service.getPunchReport(page: page, startDate: startDateFormatted, endDate: endDateFormatted);
    if (result != null) {
      punchSummary = result.summary;
      _punchCurrentPage = result.report.page;
      _punchTotalPages = result.report.totalPages;
      punchReports.addAll(result.report.docs);
    }
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
    if (selectedTabIndex.value == 0) {
      fetchAttendance();
    } else {
      fetchPunchReport();
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;
    if (selectedTabIndex.value == 0) {
      fetchAttendance();
    } else {
      fetchPunchReport();
    }
  }

  void clearFilters() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    if (selectedTabIndex.value == 0) {
      fetchAttendance();
    } else {
      fetchPunchReport();
    }
  }

  bool get hasActiveFilter => selectedStartDate.value != null || selectedEndDate.value != null;
}
