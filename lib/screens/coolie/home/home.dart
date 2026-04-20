import 'dart:async';
import 'dart:io';
import 'package:license_sahayak/routes/route_name.dart';
import 'package:license_sahayak/screens/coolie/home/home_ctrl.dart';
import 'package:license_sahayak/screens/coolie/home/ui/booking_req_ui.dart';
import 'package:license_sahayak/screens/coolie/home/ui/home_header_ui.dart';
import 'package:license_sahayak/screens/coolie/home/ui/recent_booking_history.dart';
import 'package:license_sahayak/services/suspension_service.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const _kSlate600 = Color(0xFF475569);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.exit_to_app_rounded, color: Constants.instance.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Exit App', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
          ],
        ),
        content: Text('Do you want to close the application?', style: GoogleFonts.poppins(fontSize: 14, color: _kSlate600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _kSlate600, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => exit(0),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.instance.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Exit',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: GetBuilder<HomeCtrl>(
        init: HomeCtrl(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: Column(
              children: [
                HomeHeaderUI(controller: controller),
                Expanded(
                  child: Obx(() {
                    final isSuspended = controller.userProfile.value?.isSuspended == true;
                    if (isSuspended) {
                      return _SuspendedView(user: controller.userProfile.value, onLogout: () => controller.logOut());
                    }
                    return RefreshIndicator(
                      color: Constants.instance.primary,
                      onRefresh: () async => await controller.initialize(),
                      child: controller.isLoading.value
                          ? Center(child: CircularProgressIndicator(color: Constants.instance.primary))
                          : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BookingReqUI(controller: controller),
                                  const SizedBox(height: 24),
                                  RecentBookingHistory(controller: controller),
                                ],
                              ),
                            ),
                    );
                  }),
                ),
              ],
            ),
            floatingActionButton: Obx(() {
              if (controller.userProfile.value?.isSuspended == true) {
                return const SizedBox.shrink();
              }
              return FloatingActionButton.extended(
                onPressed: () => Get.toNamed(RouteName.attendance),
                backgroundColor: Constants.instance.primary,
                icon: const Icon(Icons.fact_check_rounded, color: Colors.white),
                label: Text(
                  'Attendance',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _SuspendedView extends StatefulWidget {
  final dynamic user;
  final VoidCallback onLogout;

  const _SuspendedView({required this.user, required this.onLogout});

  @override
  State<_SuspendedView> createState() => _SuspendedViewState();
}

class _SuspendedViewState extends State<_SuspendedView> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isPermanent = false;
  DateTime? _untilDate;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final status = SuspensionService.checkSuspensionStatus(widget.user);
    if (status.suspendedUntilDate == null) {
      setState(() => _isPermanent = true);
      return;
    }
    _untilDate = status.suspendedUntilDate;
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_untilDate == null) return;
    final diff = _untilDate!.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    if (diff.isNegative) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFECEC),
              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.22), blurRadius: 36, spreadRadius: 8)],
            ),
            child: const Icon(Icons.lock_rounded, color: Color(0xFFB91C1C), size: 48),
          ),
          const SizedBox(height: 26),
          Text(
            'Account Suspended',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          Text(
            SuspensionService.getSuspensionMessage(widget.user),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: _kSlate600, height: 1.6),
          ),
          const SizedBox(height: 30),
          if (_isPermanent)
            _PillChip(icon: Icons.block_rounded, label: 'Permanently Suspended', bgColor: const Color(0xFFFFECEC), textColor: const Color(0xFFB91C1C))
          else ...[
            if (_untilDate != null)
              _PillChip(
                icon: Icons.calendar_today_rounded,
                label: 'Until ${_untilDate!.day}/${_untilDate!.month}/${_untilDate!.year}  ${_pad(_untilDate!.hour)}:${_pad(_untilDate!.minute)}',
                bgColor: const Color(0xFFFFF7ED),
                textColor: const Color(0xFF92400E),
              ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFE4E4), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_bottom_rounded, color: Color(0xFFEF4444), size: 15),
                      const SizedBox(width: 6),
                      Text(
                        'Suspension lifts in',
                        style: GoogleFonts.poppins(fontSize: 12, color: _kSlate600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _remaining == Duration.zero
                      ? Text(
                          'Lifting soon…',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF22C55E)),
                        )
                      : _CountdownDisplay(remaining: _remaining),
                ],
              ),
            ),
          ],
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
              label: Text(
                'Logout',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownDisplay extends StatelessWidget {
  final Duration remaining;

  const _CountdownDisplay({required this.remaining});

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    final units = [if (days > 0) _UnitData(_pad(days), 'Days'), _UnitData(_pad(hours), 'Hrs'), _UnitData(_pad(minutes), 'Min'), _UnitData(_pad(seconds), 'Sec')];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < units.length; i++) ...[
          _TimeBox(unit: units[i]),
          if (i < units.length - 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                ' : ',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFFB91C1C)),
              ),
            ),
        ],
      ],
    );
  }
}

class _UnitData {
  final String value;
  final String label;

  _UnitData(this.value, this.label);
}

class _TimeBox extends StatelessWidget {
  final _UnitData unit;

  const _TimeBox({required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 52,
          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: Text(
            unit.value,
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFFB91C1C)),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          unit.label,
          style: GoogleFonts.poppins(fontSize: 10, color: _kSlate600, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _PillChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _PillChip({required this.icon, required this.label, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
