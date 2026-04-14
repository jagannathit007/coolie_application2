import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/attendance_model.dart';
import 'attendance_service.dart';

class AttendanceCtrl extends GetxController {
  final _service = AttendanceService();

  final isLoading = true.obs, isLoadingMore = false.obs;
  final isApproving = ''.obs, isRejecting = ''.obs;

  final records = <AttendanceRecord>[].obs;
  MukadamInfo? mukadamInfo;
  final summary = Rxn<AttendanceSummary>();

  int _currentPage = 1, _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  final selectedStartDate = Rxn<DateTime>();
  final selectedEndDate = Rxn<DateTime>();
  final filterCollieId = ''.obs;

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
    final result = await _service.getAttendance(page: page, startDate: startDateFormatted, endDate: endDateFormatted, collieId: filterCollieId.value);
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
    if (ok) _updateRecordApproval(sessionId, 'approved');
    isApproving.value = '';
  }

  Future<void> rejectSession(String sessionId) async {
    isRejecting.value = sessionId;
    final ok = await _service.rejectSession(sessionId);
    if (ok) _updateRecordApproval(sessionId, 'rejected');
    isRejecting.value = '';
  }

  void _updateRecordApproval(String sessionId, String status) {
    final idx = records.indexWhere((r) => r.sessionId == sessionId);
    if (idx == -1) return;
    final old = records[idx];
    records[idx] = AttendanceRecord(
      sessionId: old.sessionId,
      collieId: old.collieId,
      collieName: old.collieName,
      collieMobile: old.collieMobile,
      collieBuckle: old.collieBuckle,
      collieImage: old.collieImage,
      stationName: old.stationName,
      stationCode: old.stationCode,
      checkInTime: old.checkInTime,
      checkOutTime: old.checkOutTime,
      isActive: old.isActive,
      status: old.status,
      onlineDurationHours: old.onlineDurationHours,
      onlineDurationMinutes: old.onlineDurationMinutes,
      completedJobs: old.completedJobs,
      rejectedJobs: old.rejectedJobs,
      earningsAmount: old.earningsAmount,
      dayOfWeek: old.dayOfWeek,
      date: old.date,
      approvalStatus: status,
    );
  }

  void setDateRange(DateTime start, DateTime end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;
    fetchAttendance();
  }

  void clearFilters() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    filterCollieId.value = '';
    fetchAttendance();
  }

  bool get hasActiveFilter => selectedStartDate.value != null || selectedEndDate.value != null || filterCollieId.value.isNotEmpty;
}
