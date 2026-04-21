import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:license_sahayak/screens/coolie/attendance/collie_management/collie_creation.dart';
import 'package:license_sahayak/services/helper.dart';
import '../../../utils/app_constants.dart';
import '../../../models/punch_report_model.dart';
import 'attendance_ctrl.dart';

const _kBg = Color(0xFFF7F8FA);
const _kCard = Colors.white;
const _kBorder = Color(0xFFEEF0F4);
const _kText1 = Color(0xFF111827);
const _kText2 = Color(0xFF6B7280);
const _kText3 = Color(0xFF9CA3AF);
const _kGreen = Color(0xFF16A34A);
const _kRed = Color(0xFFD32F2F);
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
          title: Text(
            'Attendance',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          actions: [
            Obx(() {
              if (ctrl.isMukadam.value) {
                return IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.white, size: 24),
                  onPressed: () => Get.to(() => CollieCreation()),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(width: 10),
          ],
          bottom: ctrl.isMukadam.value
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: _MukadamTabBar(ctrl: ctrl),
                )
              : null,
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: _FilterRow(ctrl: ctrl),
            ),
            Expanded(child: _PunchReportTab(ctrl: ctrl)),
          ],
        ),
      ),
    );
  }
}

class _MukadamTabBar extends StatelessWidget {
  final AttendanceCtrl ctrl;

  const _MukadamTabBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = ctrl.selectedTab.value;
      return Container(
        height: 44,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            _TabBtn(label: 'All Collies', icon: Icons.people_outline_rounded, isActive: current == AttendanceTab.allCollies, onTap: () => ctrl.switchTab(AttendanceTab.allCollies)),
            _TabBtn(label: 'My Attendance', icon: Icons.person_outline_rounded, isActive: current == AttendanceTab.myAttendance, onTap: () => ctrl.switchTab(AttendanceTab.myAttendance)),
          ],
        ),
      );
    });
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabBtn({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          height: 44,
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isActive ? Constants.instance.primary : Colors.white70),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? Constants.instance.primary : Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PunchReportTab extends StatelessWidget {
  final AttendanceCtrl ctrl;

  const _PunchReportTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingMore.value) return const _Shimmer();
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
                  if (i == ctrl.punchReports.length) return _LoadMore(ctrl: ctrl);
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
              _PunchStat(value: helper.formatDecimalHoursToTime(s.totalHours), label: 'Total Hours', icon: Icons.access_time_rounded, color: _kAmber),
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
              !ctrl.isMukadam.value
                  ? 'My Reports'
                  : ctrl.selectedTab.value == AttendanceTab.allCollies
                  ? 'Collie Reports'
                  : 'My Attendance',
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
    return GestureDetector(
      onTap: () => Get.to(() => CollieSessionsScreen(collie: collie)),
      child: Container(
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
                  GestureDetector(
                    onTap: collie.collieImage == null ? null : () => helper.imageShow(uri: NetworkConstants.baseUrl + collie.collieImage.toString(), context: context),
                    child: Stack(
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
                            Image.asset("assets/buckle.png", width: 18, height: 18, fit: BoxFit.contain),
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
                  _PunchTimeChip(icon: Icons.access_time_rounded, label: 'Hours', value: helper.formatDecimalHoursToTime(collie.totalHours), color: _kAmber),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.to(() => CollieSessionsScreen(collie: collie)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Constants.instance.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_view_week_rounded, size: 12, color: Constants.instance.primary),
                          const SizedBox(width: 5),
                          Text(
                            'View Sessions',
                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Constants.instance.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class CollieSessionsScreen extends StatelessWidget {
  final PunchReportCollie collie;

  const CollieSessionsScreen({super.key, required this.collie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: Constants.instance.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Constants.instance.primary, Constants.instance.primary.withOpacity(0.75)]),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: collie.collieImage == null ? null : () => helper.imageShow(uri: NetworkConstants.baseUrl + collie.collieImage.toString(), context: context),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: collie.collieImage != null ? NetworkImage(NetworkConstants.baseUrl + collie.collieImage!) : null,
                            child: collie.collieImage == null ? const Icon(Icons.person_rounded, color: Colors.white, size: 32) : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      collie.collieName,
                                      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (collie.isCurrentlyActive) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: _kGreen, borderRadius: BorderRadius.circular(20)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _PulseDot(color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Live',
                                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(collie.collieMobile, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                              const SizedBox(height: 2),
                              Text('${collie.stationName} • #${collie.buckleNumber}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.65))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              'Sessions',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: [
                  _SessionStat(value: '${collie.totalSessions}', label: 'Sessions', icon: Icons.history_rounded, color: _kBlue),
                  _vDivider(),
                  _SessionStat(value: helper.formatDecimalHoursToTime(collie.totalHours), label: 'Total Hours', icon: Icons.access_time_rounded, color: _kAmber),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Text(
                    'All Sessions',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _kText1),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: Constants.instance.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${collie.sessions.length}',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Constants.instance.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (collie.sessions.isEmpty)
            const SliverFillRemaining(child: _Empty())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _SessionDetailCard(session: collie.sessions[i], index: i),
                childCount: collie.sessions.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 40, color: _kBorder, margin: const EdgeInsets.symmetric(horizontal: 8));
}

class _SessionStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;

  const _SessionStat({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: _kText1),
          ),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: _kText3)),
        ],
      ),
    );
  }
}

class _SessionDetailCard extends StatelessWidget {
  final PunchSession session;
  final int index;

  const _SessionDetailCard({required this.session, required this.index});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: session.isActive ? _kGreen.withOpacity(0.1) : _kBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: Icon(session.isActive ? Icons.play_circle_rounded : Icons.check_circle_rounded, size: 18, color: session.isActive ? _kGreen : _kBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session ${index + 1}',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _kText1),
                      ),
                      const SizedBox(height: 2),
                      Text('${session.date}  •  ${session.dayOfWeek}', style: GoogleFonts.poppins(fontSize: 11, color: _kText2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder, indent: 14, endIndent: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                _DetailTile(icon: Icons.login_rounded, label: 'Punch In', value: helper.getFormattedTimer(session.punchIn ?? "---"), color: _kGreen),
                _vLine(),
                _DetailTile(icon: Icons.logout_rounded, label: 'Punch Out', value: helper.getFormattedTimer(session.punchOut ?? "---"), color: _kRed),
                _vLine(),
                _DetailTile(icon: Icons.timer_outlined, label: 'Duration', value: session.durationFormatted, color: _kAmber),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder, indent: 14, endIndent: 14),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _DetailTile(icon: Icons.work_outline_rounded, label: 'Completed', value: '${session.completedJobs}', color: _kGreen),
                _vLine(),
                _DetailTile(icon: Icons.work_outline_rounded, label: 'Rejected', value: '${session.rejectedJobs}', color: _kRed),
                _vLine(),
                _DetailTile(icon: Icons.currency_rupee_rounded, label: 'Earnings', value: '₹${session.earnings}', color: _kBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vLine() => Container(width: 1, height: 40, color: _kBorder, margin: const EdgeInsets.symmetric(horizontal: 12));
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _DetailTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 9.5, color: _kText3)),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: _kText1),
              ),
            ],
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
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: _DateBtn(label: ctrl.startDateDisplay, isSet: ctrl.selectedStartDate.value != null, onTap: () => _pick(context, isStart: true)),
            ),
            Container(width: 8, height: 1, color: _kText3, margin: const EdgeInsets.symmetric(horizontal: 4)),
            Expanded(
              child: _DateBtn(label: ctrl.endDateDisplay, isSet: ctrl.selectedEndDate.value != null, onTap: () => _pick(context, isStart: false)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, {required bool isStart}) async {
    final DateTime firstDate = isStart ? DateTime(2023) : (ctrl.selectedStartDate.value ?? DateTime(2023));
    final DateTime initialDate = isStart ? (ctrl.selectedStartDate.value ?? DateTime.now()) : (ctrl.selectedEndDate.value ?? ctrl.selectedStartDate.value ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
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
    ctrl.fetchPunchReport();
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
          onTap: ctrl.isLoadingMore.value ? null : ctrl.loadMorePunch,
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
            decoration: const BoxDecoration(color: _kBorder, shape: BoxShape.circle),
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
