import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import '../../../utils/app_constants.dart';
import '../../../models/attendance_model.dart';
import '../../../models/punch_report_model.dart';
import 'attendance_ctrl.dart';

const _kBg = Color(0xFFF7F8FA);
const _kCard = Colors.white;
const _kBorder = Color(0xFFEEF0F4);
const _kText1 = Color(0xFF111827);
const _kText2 = Color(0xFF6B7280);
const _kText3 = Color(0xFF9CA3AF);
const _kGreen = Color(0xFF16A34A);
const _kRed = Color(0xFFDC2626);
const _kBlue = Color(0xFF2563EB);
const _kAmber = Color(0xFFD97706);

class Attendance extends StatelessWidget {
  const Attendance({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceCtrl>(
      init: AttendanceCtrl(),
      builder: (ctrl) => Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Constants.instance.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                if (ctrl.selectedTabIndex.value == 0 && ctrl.mukadamInfo != null)
                  Text('${ctrl.mukadamInfo!.station?.name ?? ''} · ${ctrl.mukadamInfo!.shiftTiming ?? ''}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.75))),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Obx(() => Row(children: [_buildTab(ctrl, 'Attendance', 0), _buildTab(ctrl, 'Punch Report', 1)])),
            ),
            _FilterRow(ctrl: ctrl),
            Expanded(
              child: Obx(() {
                if (ctrl.selectedTabIndex.value == 0) {
                  return _AttendanceTab(ctrl: ctrl);
                } else {
                  return _PunchReportTab(ctrl: ctrl);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(AttendanceCtrl ctrl, String title, int index) {
    final isSelected = ctrl.selectedTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => ctrl.onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: isSelected ? Constants.instance.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : _kText2),
          ),
        ),
      ),
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  final AttendanceCtrl ctrl;

  const _AttendanceTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) return const _Shimmer();
      return RefreshIndicator(
        color: Constants.instance.primary,
        onRefresh: ctrl.fetchAttendance,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _RecordsHeader(ctrl: ctrl)),
            if (ctrl.records.isEmpty)
              const SliverFillRemaining(child: _Empty())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  if (i == ctrl.records.length) return _LoadMore(ctrl: ctrl);
                  return _AttendanceCard(record: ctrl.records[i], ctrl: ctrl);
                }, childCount: ctrl.records.length + (ctrl.hasMore ? 1 : 0)),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      );
    });
  }
}

class _RecordsHeader extends StatelessWidget {
  final AttendanceCtrl ctrl;

  const _RecordsHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Text(
              'Records',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _kText1),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: Constants.instance.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
              child: Text(
                '${ctrl.records.length}',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Constants.instance.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  final AttendanceCtrl ctrl;

  const _AttendanceCard({required this.record, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isOnline = record.isActive;
    return Obx(() {
      final sid = record.sessionId ?? '';
      final approvalStatus = record.approvalStatus;
      final isPending = approvalStatus == null || approvalStatus == 'pending';
      final isApproving = ctrl.isApproving.value == sid;
      final isRejecting = ctrl.isRejecting.value == sid;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Constants.instance.primary.withOpacity(0.1),
                        backgroundImage: record.collieImage != null ? NetworkImage(NetworkConstants.baseUrl + record.collieImage!) : null,
                        child: record.collieImage == null ? Icon(Icons.person_rounded, color: Constants.instance.primary, size: 22) : null,
                      ),
                      if (isOnline)
                        Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _kGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                record.collieName ?? 'Unknown',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _kText1),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusPill(isOnline: isOnline),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 11, color: _kText3),
                            const SizedBox(width: 4),
                            Text(record.collieMobile ?? '-', style: GoogleFonts.poppins(fontSize: 11, color: _kText2)),
                            if (record.collieBuckle != null) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.badge_outlined, size: 11, color: _kText3),
                              const SizedBox(width: 4),
                              Text('#${record.collieBuckle}', style: GoogleFonts.poppins(fontSize: 11, color: _kText2)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  _TimeChip(icon: Icons.login_rounded, label: 'In', value: _fmt(record.checkInTime), color: _kBlue),
                  const Spacer(),
                  _TimeChip(icon: Icons.logout_rounded, label: 'Out', value: isOnline ? 'Active' : _fmt(record.checkOutTime), color: isOnline ? _kGreen : _kText2),
                  const Spacer(),
                  _TimeChip(icon: Icons.access_time_rounded, label: 'Duration', value: '${record.onlineDurationHours.toStringAsFixed(1)}h', color: _kAmber),
                  const Spacer(),
                  _TimeChip(icon: Icons.work_outline_rounded, label: 'Jobs', value: '${record.completedJobs}✓ / ${record.rejectedJobs}✗', color: _kText2),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (isPending && sid.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _Btn(
                        label: 'Reject',
                        icon: Icons.close_rounded,
                        color: _kRed,
                        isLoading: isRejecting,
                        filled: false,
                        onTap: () {
                          _confirm(context, title: 'Reject login?', message: 'Reject this collie login request.', confirmLabel: 'Reject', color: _kRed, onConfirm: () => ctrl.rejectSession(sid));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Btn(label: 'Approve', icon: Icons.check_rounded, color: _kGreen, isLoading: isApproving, filled: true, onTap: () => ctrl.approveSession(sid)),
                    ),
                  ],
                ),
              ),
            ] else if (!isPending && (approvalStatus).isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  children: [
                    Icon(approvalStatus == 'approved' ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 14, color: approvalStatus == 'approved' ? _kGreen : _kRed),
                    const SizedBox(width: 6),
                    Text(
                      approvalStatus == 'approved' ? 'Approved by Mukadam' : 'Rejected by Mukadam',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: approvalStatus == 'approved' ? _kGreen : _kRed),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _fmt(String? iso) {
    if (iso == null) return '-';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return '-';
    }
  }

  Future<void> _confirm(BuildContext context, {required String title, required String message, required String confirmLabel, required Color color, required VoidCallback onConfirm}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13, color: _kText2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: _kText2)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel, style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) onConfirm();
  }
}

class _PunchReportTab extends StatelessWidget {
  final AttendanceCtrl ctrl;

  const _PunchReportTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingPunchReport.value) return const _Shimmer();
      return RefreshIndicator(
        color: Constants.instance.primary,
        onRefresh: () => ctrl.fetchPunchReport(),
        child: CustomScrollView(
          slivers: [
            if (ctrl.punchSummary != null) SliverToBoxAdapter(child: _PunchSummary(ctrl: ctrl)),
            SliverToBoxAdapter(child: _PunchRecordsHeader(ctrl: ctrl)),
            if (ctrl.punchReports.isEmpty)
              const SliverFillRemaining(child: _Empty())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  if (i == ctrl.punchReports.length) return _LoadMorePunch(ctrl: ctrl);
                  return _PunchCard(collie: ctrl.punchReports[i], ctrl: ctrl);
                }, childCount: ctrl.punchReports.length + (ctrl.hasMorePunch ? 1 : 0)),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      );
    });
  }
}

class _PunchSummary extends StatelessWidget {
  final AttendanceCtrl ctrl;

  const _PunchSummary({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final s = ctrl.punchSummary;
    if (s == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Overview',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _kText1),
              ),
              const Spacer(),
              if (s.activeSessions > 0)
                Row(
                  children: [
                    _PulseDot(color: _kGreen),
                    const SizedBox(width: 5),
                    Text(
                      '${s.activeSessions} active',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _kGreen),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _PunchStat(value: '${s.totalSessions}', label: 'Sessions', icon: Icons.history_rounded, color: _kBlue),
              _divider(),
              _PunchStat(value: '${s.uniqueCollies}', label: 'Collies', icon: Icons.people_outline_rounded, color: Constants.instance.primary),
              _divider(),
              _PunchStat(value: '${s.totalHours.toStringAsFixed(1)}h', label: 'Total Hours', icon: Icons.access_time_rounded, color: _kAmber),
              _divider(),
              _PunchStat(value: '${s.totalMinutes}m', label: 'Total Mins', icon: Icons.timer_rounded, color: _kText2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: _kBorder);
}

class _PunchStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;

  const _PunchStat({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: _kText1, height: 1),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 9.5, color: _kText3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PunchRecordsHeader extends StatelessWidget {
  final AttendanceCtrl ctrl;

  const _PunchRecordsHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Text(
              'Collie Reports',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _kText1),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: Constants.instance.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
              child: Text(
                '${ctrl.punchReports.length}',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Constants.instance.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PunchCard extends StatelessWidget {
  final PunchReportCollie collie;
  final AttendanceCtrl ctrl;

  const _PunchCard({required this.collie, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Constants.instance.primary.withOpacity(0.1),
                      backgroundImage: collie.collieImage != null ? NetworkImage(NetworkConstants.baseUrl + collie.collieImage!) : null,
                      child: collie.collieImage == null ? Icon(Icons.person_rounded, color: Constants.instance.primary, size: 22) : null,
                    ),
                    if (collie.isCurrentlyActive)
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _kGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              collie.collieName,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _kText1),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PunchStatusPill(isOnline: collie.isCurrentlyActive),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 11, color: _kText3),
                          const SizedBox(width: 4),
                          Text(collie.collieMobile, style: GoogleFonts.poppins(fontSize: 11, color: _kText2)),
                          const SizedBox(width: 10),
                          Icon(Icons.badge_outlined, size: 11, color: _kText3),
                          const SizedBox(width: 4),
                          Text(collie.buckleNumber, style: GoogleFonts.poppins(fontSize: 11, color: _kText2)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 11, color: _kText3),
                          const SizedBox(width: 4),
                          Text('${collie.stationName} (${collie.stationCode})', style: GoogleFonts.poppins(fontSize: 10, color: _kText2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                _PunchTimeChip(icon: Icons.history_rounded, label: 'Sessions', value: '${collie.totalSessions}', color: _kBlue),
                const Spacer(),
                _PunchTimeChip(icon: Icons.access_time_rounded, label: 'Hours', value: '${collie.totalHours.toStringAsFixed(1)}h', color: _kAmber),
                const Spacer(),
                _PunchTimeChip(icon: Icons.work_outline_rounded, label: 'Jobs', value: '${collie.totalCompleted}✓ / ${collie.totalRejected}✗', color: _kText2),
                const Spacer(),
                _PunchTimeChip(icon: Icons.currency_rupee_rounded, label: 'Earnings', value: '₹${collie.totalEarnings}', color: _kGreen),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (collie.sessions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sessions',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _kText3),
                  ),
                  const SizedBox(height: 6),
                  ...collie.sessions.map((session) => _SessionTile(session: session)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final PunchSession session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(session.isActive ? Icons.play_circle_rounded : Icons.check_circle_rounded, size: 14, color: session.isActive ? _kGreen : _kBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.date} • ${session.dayOfWeek}',
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: _kText1),
                ),
                Text('${session.durationFormatted} • ${session.completedJobs} jobs • ₹${session.earnings}', style: GoogleFonts.poppins(fontSize: 9, color: _kText2)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: session.approvalStatus == 'approved' ? _kGreen.withOpacity(0.1) : _kRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(
              session.approvalStatus,
              style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w600, color: session.approvalStatus == 'approved' ? _kGreen : _kRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _PunchStatusPill extends StatelessWidget {
  final bool isOnline;

  const _PunchStatusPill({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? _kGreen : _kText3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(
        isOnline ? 'Online' : 'Offline',
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _PunchTimeChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _PunchTimeChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _kText1),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 9.5, color: _kText3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  final AttendanceCtrl ctrl;

  const _FilterRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: _DateBtn(label: ctrl.startDateDisplay, isSet: ctrl.selectedStartDate.value != null, onTap: () => _pick(context, isStart: true)),
            ),
            Container(width: 8, height: 1, color: _kText3, margin: const EdgeInsets.symmetric(horizontal: 4)),
            Expanded(
              child: _DateBtn(label: ctrl.endDateDisplay, isSet: ctrl.selectedEndDate.value != null, onTap: () => _pick(context, isStart: false)),
            ),
            if (ctrl.hasActiveFilter) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: ctrl.clearFilters,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(color: _kRed.withOpacity(0.08), borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.close_rounded, size: 16, color: _kRed),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, {required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: Constants.instance.primary)),
        child: child!,
      ),
    );
    if (picked == null) return;
    if (isStart) {
      ctrl.selectedStartDate.value = picked;
      if (ctrl.selectedEndDate.value == null || ctrl.selectedEndDate.value!.isBefore(picked)) {
        ctrl.selectedEndDate.value = picked;
      }
    } else {
      ctrl.selectedEndDate.value = picked;
    }
    if (ctrl.selectedTabIndex.value == 0) {
      ctrl.fetchAttendance();
    } else {
      ctrl.fetchPunchReport();
    }
  }
}

class _DateBtn extends StatelessWidget {
  final String label;
  final bool isSet;
  final VoidCallback onTap;

  const _DateBtn({required this.label, required this.isSet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = Constants.instance.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSet ? active.withOpacity(0.06) : _kCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSet ? active.withOpacity(0.35) : _kBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 13, color: isSet ? active : _kText3),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: isSet ? FontWeight.w600 : FontWeight.w400, color: isSet ? active : _kText2),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isOnline;

  const _StatusPill({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? _kGreen : _kText3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(
        isOnline ? 'Online' : 'Offline',
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _TimeChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _kText1),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 9.5, color: _kText3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading, filled;
  final VoidCallback onTap;

  const _Btn({required this.label, required this.icon, required this.color, required this.isLoading, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2, color: filled ? Colors.white : color))
            else
              Icon(icon, size: 14, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              isLoading ? 'Wait...' : label,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: filled ? Colors.white : color),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;

  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _a = Tween<double>(begin: 0.4, end: 1.0).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, _) => Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color.withOpacity(_a.value)),
    ),
  );
}

class _LoadMore extends StatelessWidget {
  final AttendanceCtrl ctrl;

  const _LoadMore({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: GestureDetector(
          onTap: ctrl.isLoadingMore.value ? null : ctrl.loadMore,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Center(
              child: ctrl.isLoadingMore.value
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Constants.instance.primary))
                  : Text(
                      'Load more',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Constants.instance.primary),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadMorePunch extends StatelessWidget {
  final AttendanceCtrl ctrl;

  const _LoadMorePunch({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: GestureDetector(
          onTap: ctrl.isLoadingMorePunch.value ? null : ctrl.loadMorePunch,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Center(
              child: ctrl.isLoadingMorePunch.value
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Constants.instance.primary))
                  : Text(
                      'Load more',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Constants.instance.primary),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _kBorder, shape: BoxShape.circle),
            child: const Icon(Icons.event_busy_rounded, size: 36, color: _kText3),
          ),
          const SizedBox(height: 16),
          Text(
            'No records found',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: _kText2),
          ),
          const SizedBox(height: 4),
          Text('Try adjusting the date filter', style: GoogleFonts.poppins(fontSize: 12, color: _kText3)),
        ],
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer();

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _a = Tween<double>(begin: -1, end: 2).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, _) => AnimatedBuilder(
        animation: _a,
        builder: (_, _) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              stops: [(_a.value - 0.3).clamp(0.0, 1.0), _a.value.clamp(0.0, 1.0), (_a.value + 0.3).clamp(0.0, 1.0)],
              colors: const [Color(0xFFEEF0F4), Color(0xFFF7F8FA), Color(0xFFEEF0F4)],
            ),
          ),
        ),
      ),
    );
  }
}
