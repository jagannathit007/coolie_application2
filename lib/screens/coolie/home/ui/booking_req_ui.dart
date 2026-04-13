import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/models/get_passenger_coolie_model.dart';
import 'package:license_sahayak/screens/coolie/home/home_ctrl.dart';
import 'package:license_sahayak/utils/app_constants.dart';

const _kBlue = Color(0xFF3B82F6);
const _kGreen = Color(0xFF22C55E);
const _kOrange = Color(0xFFF97316);
const _kSlate50 = Color(0xFFF8FAFC);
const _kSlate100 = Color(0xFFF1F5F9);
const _kSlate200 = Color(0xFFE2E8F0);
const _kSlate400 = Color(0xFF94A3B8);
const _kSlate600 = Color(0xFF475569);
const _kSlate900 = Color(0xFF0F172A);

class BookingReqUI extends StatelessWidget {
  final HomeCtrl controller;

  const BookingReqUI({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final booking = controller.passengerDetails.value.booking;
      final status = controller.checkStatuss.value.toLowerCase();
      final checkedIn = controller.isCheckedIn.value;
      if (!checkedIn) {
        return _InfoBanner(icon: Icons.fingerprint_rounded, title: 'Check In to Start', subtitle: 'Tap "Check In" above to go on duty and receive passenger requests.', color: _kBlue);
      }
      if (booking == null) {
        return _InfoBanner(icon: Icons.radar_rounded, title: 'Waiting for Requests', subtitle: 'You\'re on duty. New booking requests will appear here automatically.', color: _kGreen);
      }
      if (status == 'pending') {
        return _PendingRequestCard(controller: controller, booking: booking);
      }
      if (status == 'accepted' || status == 'in-progress') {
        return _ActiveJobCard(controller: controller, booking: booking);
      }
      return const SizedBox.shrink();
    });
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoBanner({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 28),
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

  const _PendingRequestCard({required this.controller, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          _PendingHeader(controller: controller),
          _PassengerHighlight(booking: booking),
          _TripDetailGrid(booking: booking),
          _ActionButtons(controller: controller, booking: booking),
        ],
      ),
    );
  }
}

class _PendingHeader extends StatelessWidget {
  final HomeCtrl controller;

  const _PendingHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: _kOrange,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.20), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Booking Request!',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text('Respond before time runs out', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.75), fontSize: 11)),
              ],
            ),
          ),
          Obx(() => _CountdownBadge(time: controller.countdownTime.value)),
        ],
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final String time;

  const _CountdownBadge({required this.time});

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
        color: isUrgent ? Colors.red.shade700 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: isUrgent ? Colors.red.withOpacity(0.4) : Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, color: isUrgent ? Colors.white : _kOrange, size: 16),
          const SizedBox(width: 5),
          Text(
            time,
            style: GoogleFonts.poppins(color: isUrgent ? Colors.white : _kOrange, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _PassengerHighlight extends StatelessWidget {
  final Booking booking;

  const _PassengerHighlight({required this.booking});

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
            backgroundColor: _kBlue.withOpacity(0.12),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: _kBlue),
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

  const _TripDetailGrid({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GridTile(icon: Icons.train_rounded, label: 'Station', value: booking.pickupDetails?.station?.toString() ?? 'N/A'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GridTile(icon: Icons.event_seat_rounded, label: 'Coach', value: booking.pickupDetails?.coachNumber?.toString() ?? 'N/A'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _GridTile(icon: Icons.flag_rounded, label: 'Drop', value: booking.destination?.toString() ?? 'N/A'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GridTile(icon: Icons.scale_rounded, label: 'Weight', value: '${booking.pickupDetails?.weight ?? "?"}kg'),
              ),
            ],
          ),
          if ((booking.pickupDetails?.description?.toString() ?? '').isNotEmpty && booking.pickupDetails?.description?.toString() != 'N/A') ...[
            const SizedBox(height: 10),
            _NoteRow(note: booking.pickupDetails?.description?.toString() ?? ''),
          ],
        ],
      ),
    );
  }
}

class _GridTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GridTile({required this.icon, required this.label, required this.value});

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
            decoration: BoxDecoration(color: Constants.instance.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: Constants.instance.primary),
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

  const _NoteRow({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notes_rounded, size: 16, color: Color(0xFFD97706)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF92400E), fontWeight: FontWeight.w500),
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

  const _ActionButtons({required this.controller, required this.booking});

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
                    color: _kGreen,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: _kGreen.withOpacity(0.40), blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: controller.isLoading.value
                      ? const Center(
                          child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Accept Job',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
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

  const _ActiveJobCard({required this.controller, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.checkStatuss.value.toLowerCase();
      final isInProgress = status == 'in-progress';
      final headerColor = isInProgress ? _kBlue : _kGreen;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: headerColor.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            _ActiveHeader(controller: controller, isInProgress: isInProgress, headerColor: headerColor),
            _ActiveDetailGrid(booking: booking, isInProgress: isInProgress),
            _ActiveCTAButton(controller: controller, booking: booking, isInProgress: isInProgress),
          ],
        ),
      );
    });
  }
}

class _ActiveHeader extends StatelessWidget {
  final HomeCtrl controller;
  final bool isInProgress;
  final Color headerColor;

  const _ActiveHeader({required this.controller, required this.isInProgress, required this.headerColor});

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
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.20), borderRadius: BorderRadius.circular(10)),
            child: Icon(isInProgress ? Icons.directions_walk_rounded : Icons.check_circle_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isInProgress ? 'Job In Progress' : 'Job Accepted',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(isInProgress ? 'Time elapsed since start' : 'Verify OTP to begin the job', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.75), fontSize: 11)),
              ],
            ),
          ),
          Obx(() => _ElapsedBadge(time: controller.elapsedTime.value)),
        ],
      ),
    );
  }
}

class _ElapsedBadge extends StatelessWidget {
  final String time;

  const _ElapsedBadge({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_rounded, color: _kBlue, size: 16),
          const SizedBox(width: 5),
          Text(
            time,
            style: GoogleFonts.poppins(color: _kBlue, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _ActiveDetailGrid extends StatelessWidget {
  final Booking booking;
  final bool isInProgress;

  const _ActiveDetailGrid({required this.booking, required this.isInProgress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GridTile(icon: Icons.train_rounded, label: 'Station', value: booking.pickupDetails?.station?.toString() ?? 'N/A'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GridTile(icon: Icons.event_seat_rounded, label: 'Coach', value: booking.pickupDetails?.coachNumber?.toString() ?? 'N/A'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _GridTile(icon: Icons.flag_rounded, label: 'Drop', value: booking.destination?.toString() ?? 'N/A'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GridTile(icon: Icons.scale_rounded, label: 'Weight', value: '${booking.pickupDetails?.weight ?? "?"}kg'),
              ),
            ],
          ),
          if ((booking.pickupDetails?.description?.toString() ?? '').isNotEmpty && booking.pickupDetails?.description?.toString() != 'N/A') ...[
            const SizedBox(height: 10),
            _NoteRow(note: booking.pickupDetails?.description?.toString() ?? ''),
          ],
        ],
      ),
    );
  }
}

class _ActiveCTAButton extends StatelessWidget {
  final HomeCtrl controller;
  final Booking booking;
  final bool isInProgress;

  const _ActiveCTAButton({required this.controller, required this.booking, required this.isInProgress});

  @override
  Widget build(BuildContext context) {
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
              color: isInProgress ? _kGreen : Constants.instance.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: (isInProgress ? _kGreen : Constants.instance.primary).withOpacity(0.38), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: controller.isLoading.value
                ? const Center(
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.20), borderRadius: BorderRadius.circular(10)),
                        child: Icon(isInProgress ? Icons.task_alt_rounded : Icons.lock_open_rounded, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isInProgress ? 'Complete Service' : 'Verify OTP to Start',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          Text(isInProgress ? 'Mark this job as done' : 'Enter OTP shared by passenger', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.75))),
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
