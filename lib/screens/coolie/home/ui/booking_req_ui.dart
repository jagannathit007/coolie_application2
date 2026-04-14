import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/models/get_passenger_coolie_model.dart';
import 'package:license_sahayak/screens/coolie/home/home_ctrl.dart';
import 'package:license_sahayak/utils/app_constants.dart';

const _kWhite = Colors.white;
const _kSlate50 = Color(0xFFF8FAFC);
const _kSlate100 = Color(0xFFF1F5F9);
const _kSlate200 = Color(0xFFE2E8F0);
const _kSlate400 = Color(0xFF94A3B8);
const _kSlate600 = Color(0xFF475569);
const _kSlate800 = Color(0xFF1E293B);
const _kSlate900 = Color(0xFF0F172A);
const _kSuccess = Color(0xFF16A34A);

class BookingReqUI extends StatelessWidget {
  final HomeCtrl controller;

  const BookingReqUI({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final primary = Constants.instance.primary;
    return Obx(() {
      final booking = controller.passengerDetails.value.booking;
      final status = controller.checkStatuss.value.toLowerCase();
      final checkedIn = controller.isCheckedIn.value;
      if (!checkedIn) {
        return _InfoBanner(icon: Icons.fingerprint_rounded, title: 'Check In to Start', subtitle: 'Tap "Check In" above to go on duty and receive passenger requests.', primary: primary);
      }
      if (booking == null) {
        return _InfoBanner(icon: Icons.radar_rounded, title: 'Waiting for Requests', subtitle: 'You\'re on duty. New booking requests will appear here automatically.', primary: primary);
      }
      if (status == 'pending') {
        return _PendingRequestCard(controller: controller, booking: booking, primary: primary);
      }
      if (status == 'accepted' || status == 'in-progress') {
        return _ActiveJobCard(controller: controller, booking: booking, primary: primary);
      }
      return const SizedBox.shrink();
    });
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primary;

  const _InfoBanner({required this.icon, required this.title, required this.subtitle, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kSlate900),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: _kSlate400, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  final HomeCtrl controller;
  final Booking booking;
  final Color primary;

  const _PendingRequestCard({required this.controller, required this.booking, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          _PendingHeader(controller: controller, primary: primary),
          _PassengerHighlight(booking: booking, primary: primary),
          _TripDetailGrid(booking: booking, primary: primary),
          _ActionButtons(controller: controller, booking: booking, primary: primary),
        ],
      ),
    );
  }
}

class _PendingHeader extends StatelessWidget {
  final HomeCtrl controller;
  final Color primary;

  const _PendingHeader({required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: _kWhite.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.notifications_active_rounded, color: _kWhite, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Booking Request!',
                  style: GoogleFonts.poppins(color: _kWhite, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text('Respond before time runs out', style: GoogleFonts.poppins(color: _kWhite.withOpacity(0.72), fontSize: 11)),
              ],
            ),
          ),
          Obx(() => _CountdownBadge(time: controller.countdownTime.value, primary: primary)),
        ],
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final String time;
  final Color primary;

  const _CountdownBadge({required this.time, required this.primary});

  @override
  Widget build(BuildContext context) {
    final parts = time.split(':');
    int totalSeconds = 0;
    if (parts.length == 2) {
      totalSeconds = (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
    }
    final isUrgent = totalSeconds <= 10;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent ? _kSlate900 : _kWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: (isUrgent ? _kSlate900 : _kWhite).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, color: isUrgent ? _kWhite : primary, size: 16),
          const SizedBox(width: 5),
          Text(
            time,
            style: GoogleFonts.poppins(color: isUrgent ? _kWhite : primary, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _PassengerHighlight extends StatelessWidget {
  final Booking booking;
  final Color primary;

  const _PassengerHighlight({required this.booking, required this.primary});

  @override
  Widget build(BuildContext context) {
    final name = booking.passengerId?.name?.toString() ?? 'N/A';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kSlate50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kSlate200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primary.withOpacity(0.10),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: primary),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passenger', style: GoogleFonts.poppins(fontSize: 11, color: _kSlate400)),
              Text(
                name,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kSlate900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripDetailGrid extends StatelessWidget {
  final Booking booking;
  final Color primary;

  const _TripDetailGrid({required this.booking, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GridTile(icon: Icons.train_rounded, label: 'Station', value: booking.pickupDetails?.station?.toString() ?? 'N/A', primary: primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GridTile(icon: Icons.event_seat_rounded, label: 'Coach', value: booking.pickupDetails?.coachNumber?.toString() ?? 'N/A', primary: primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _GridTile(icon: Icons.flag_rounded, label: 'Drop', value: booking.destination?.toString() ?? 'N/A', primary: primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GridTile(icon: Icons.scale_rounded, label: 'Weight', value: '${booking.pickupDetails?.weight ?? "?"}kg', primary: primary),
              ),
            ],
          ),
          Builder(
            builder: (_) {
              final desc = booking.pickupDetails?.description?.toString() ?? '';
              if (desc.isEmpty || desc == 'N/A') return const SizedBox.shrink();
              return Column(
                children: [
                  const SizedBox(height: 10),
                  _NoteRow(note: desc, primary: primary),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GridTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color primary;

  const _GridTile({required this.icon, required this.label, required this.value, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kSlate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kSlate200),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 10, color: _kSlate400)),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _kSlate900),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final String note;
  final Color primary;

  const _NoteRow({required this.note, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.notes_rounded, size: 16, color: primary.withOpacity(0.70)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: GoogleFonts.poppins(fontSize: 12, color: _kSlate800, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final HomeCtrl controller;
  final Booking booking;
  final Color primary;

  const _ActionButtons({required this.controller, required this.booking, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: controller.isLoading.value ? null : () => controller.bookPassenger(booking.id.toString(), false),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: _kSlate100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kSlate200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.close_rounded, size: 20, color: _kSlate600),
                      const SizedBox(width: 6),
                      Text(
                        'Decline',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _kSlate600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: controller.isLoading.value ? null : () => controller.bookPassenger(booking.id.toString(), true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 54,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: primary.withOpacity(0.38), blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: controller.isLoading.value
                      ? const Center(
                          child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: _kWhite)),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 20, color: _kWhite),
                            const SizedBox(width: 8),
                            Text(
                              'Accept Job',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kWhite),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final HomeCtrl controller;
  final Booking booking;
  final Color primary;

  const _ActiveJobCard({required this.controller, required this.booking, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isInProgress = controller.checkStatuss.value.toLowerCase() == 'in-progress';
      final headerColor = isInProgress ? _kSuccess : primary;
      return Container(
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: headerColor.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            _ActiveHeader(isInProgress: isInProgress, headerColor: headerColor),
            _ActiveDetailGrid(booking: booking, primary: primary),
            _ActiveCTAButton(controller: controller, booking: booking, isInProgress: isInProgress, primary: primary),
          ],
        ),
      );
    });
  }
}

class _ActiveHeader extends StatelessWidget {
  final bool isInProgress;
  final Color headerColor;

  const _ActiveHeader({required this.isInProgress, required this.headerColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: _kWhite.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
            child: Icon(isInProgress ? Icons.directions_walk_rounded : Icons.check_circle_rounded, color: _kWhite, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isInProgress ? 'Job In Progress' : 'Job Accepted',
                style: GoogleFonts.poppins(color: _kWhite, fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(isInProgress ? 'Time elapsed since start' : 'Verify OTP to begin the job', style: GoogleFonts.poppins(color: _kWhite.withOpacity(0.72), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveDetailGrid extends StatelessWidget {
  final Booking booking;
  final Color primary;

  const _ActiveDetailGrid({required this.booking, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GridTile(icon: Icons.train_rounded, label: 'Station', value: booking.pickupDetails?.station?.toString() ?? 'N/A', primary: primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GridTile(icon: Icons.event_seat_rounded, label: 'Coach', value: booking.pickupDetails?.coachNumber?.toString() ?? 'N/A', primary: primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _GridTile(icon: Icons.flag_rounded, label: 'Drop', value: booking.destination?.toString() ?? 'N/A', primary: primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GridTile(icon: Icons.scale_rounded, label: 'Weight', value: '${booking.pickupDetails?.weight ?? "?"}kg', primary: primary),
              ),
            ],
          ),
          Builder(
            builder: (_) {
              final desc = booking.pickupDetails?.description?.toString() ?? '';
              if (desc.isEmpty || desc == 'N/A') return const SizedBox.shrink();
              return Column(
                children: [
                  const SizedBox(height: 10),
                  _NoteRow(note: desc, primary: primary),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActiveCTAButton extends StatelessWidget {
  final HomeCtrl controller;
  final Booking booking;
  final bool isInProgress;
  final Color primary;

  const _ActiveCTAButton({required this.controller, required this.booking, required this.isInProgress, required this.primary});

  @override
  Widget build(BuildContext context) {
    final btnColor = isInProgress ? _kSuccess : primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Obx(
        () => GestureDetector(
          onTap: controller.isLoading.value
              ? null
              : isInProgress
              ? () => controller.completeService(booking.id?.toString())
              : () => controller.verifyBooking(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 58,
            width: double.infinity,
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: btnColor.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: controller.isLoading.value
                ? const Center(
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: _kWhite)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: _kWhite.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
                        child: Icon(isInProgress ? Icons.task_alt_rounded : Icons.lock_open_rounded, size: 20, color: _kWhite),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isInProgress ? 'Complete Service' : 'Verify OTP to Start',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kWhite),
                          ),
                          Text(isInProgress ? 'Mark this job as done' : 'Enter OTP shared by passenger', style: GoogleFonts.poppins(fontSize: 11, color: _kWhite.withOpacity(0.72))),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
