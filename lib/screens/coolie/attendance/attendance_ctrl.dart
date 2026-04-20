import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:license_sahayak/models/punch_report_model.dart';
import 'package:license_sahayak/models/user_model.dart';
import '../../../services/app_storage.dart';
import 'attendance_service.dart';

enum AttendanceTab { allCollies, myAttendance }

class AttendanceCtrl extends GetxController {
  final _service = AttendanceService();
  final isLoading = true.obs, isLoadingMore = false.obs, isMukadam = false.obs;
  final selectedTab = AttendanceTab.allCollies.obs;
  final punchReports = <PunchReportCollie>[].obs;
  PunchReportSummary? punchSummary;
  int _punchCurrentPage = 1, _punchTotalPages = 1;

  bool get hasMorePunch => _punchCurrentPage < _punchTotalPages;

  final selectedStartDate = Rxn<DateTime>(DateTime.now());
  final selectedEndDate = Rxn<DateTime>(DateTime.now());

  String get startDateFormatted => selectedStartDate.value != null ? DateFormat('yyyy-MM-dd').format(selectedStartDate.value!) : '';

  String get endDateFormatted => selectedEndDate.value != null ? DateFormat('yyyy-MM-dd').format(selectedEndDate.value!) : '';

  String get startDateDisplay => selectedStartDate.value != null ? DateFormat('dd MMM yyyy').format(selectedStartDate.value!) : 'Start Date';

  String get endDateDisplay => selectedEndDate.value != null ? DateFormat('dd MMM yyyy').format(selectedEndDate.value!) : 'End Date';

  User? _currentUser;

  String get _currentUserId => _currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    isMukadam.value = AppStorage.read("isMukadam") ?? false;
    fetchPunchReport();
  }

  void switchTab(AttendanceTab tab) {
    if (selectedTab.value == tab) return;
    selectedTab.value = tab;
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
    if (_currentUser == null) {
      final response = AppStorage.read('user');
      final decoded = json.decode(response);
      _currentUser = User.fromJson(decoded);
    }
    String collieId = '', mukadamId = '';
    if (isMukadam.value) {
      mukadamId = _currentUserId;
    } else {
      collieId = _currentUserId;
      mukadamId = '';
    }
    final result = await _service.getPunchReport(page: page, collieId: collieId, mukadamId: mukadamId, startDate: startDateFormatted, endDate: endDateFormatted);
    if (result != null) {
      punchSummary = result.summary;
      _punchCurrentPage = result.report.page;
      _punchTotalPages = result.report.totalPages;
      List<PunchReportCollie> reportsToAdd = [];
      if (isMukadam.value && selectedTab.value == AttendanceTab.allCollies) {
        reportsToAdd = result.report.docs.where((report) => report.workerType == 'collie').toList();
      } else if (isMukadam.value && selectedTab.value == AttendanceTab.myAttendance) {
        reportsToAdd = result.report.docs.where((report) => report.workerType != 'collie').toList();
      } else {
        reportsToAdd = result.report.docs;
      }
      if (page == 1) {
        punchReports.value = reportsToAdd;
      } else {
        punchReports.addAll(reportsToAdd);
      }
    }
  }

  void clearFilters() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    fetchPunchReport();
  }

  bool get hasActiveFilter => selectedStartDate.value != null || selectedEndDate.value != null;
}
