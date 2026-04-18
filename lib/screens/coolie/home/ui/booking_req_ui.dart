import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:license_sahayak/models/get_passenger_coolie_model.dart';
import 'package:license_sahayak/screens/coolie/home/home_ctrl.dart';
import 'package:license_sahayak/services/helper.dart';
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 6))],
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          _PendingHeader(controller: controller, primary: primary),
          _PassengerHighlight(booking: booking, primary: primary),
          _TripRouteSection(booking: booking, primary: primary),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                Text(
                  'Respond before time runs out',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: _kWhite.withOpacity(0.72), fontSize: 11),
                ),
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
    final name = booking.passengerId?.name.toString() ?? 'N/A';
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

class _TripRouteSection extends StatelessWidget {
  final Booking booking;
  final Color primary;

  const _TripRouteSection({required this.booking, required this.primary});

  @override
  Widget build(BuildContext context) {
    final station = booking.pickupDetails?.station?.toString() ?? 'N/A';
    final coach = booking.pickupDetails?.coachNumber?.toString();
    final dest = booking.destination?.toString() ?? 'N/A';
    final weight = booking.pickupDetails?.weightStatus == "verified" ? booking.pickupDetails?.weight?.toString() : booking.pickupDetails?.originalWeight?.toString();
    final desc = booking.pickupDetails?.description?.toString() ?? '';
    final fare = booking.fare?.baseFare?.toString() ?? '—';
    final pnrNumber = booking.pickupDetails?.pnrNumber?.toString() ?? 'N/A';
    final utsNumber = booking.pickupDetails?.utsNumber?.toString() ?? 'N/A';
    final trainNumber = booking.pickupDetails?.trainNumber?.toString() ?? 'N/A';
    final ticketType = booking.pickupDetails?.ticketType?.toString() ?? 'N/A';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _kSlate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kSlate200, width: 0.9),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteLine(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RouteStop(label: 'PICKUP', value: station, labelColor: const Color(0xFF16A34A)),
                      const SizedBox(height: 20),
                      _RouteStop(label: 'DESTINATION', value: dest, labelColor: const Color(0xFFDC2626)),
                    ],
                  ),
                ),
                if (ticketType.isNotEmpty) ...[SizedBox(width: 10), _CoachTag(coach: ticketType.capitalizeFirst.toString())],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetaChip(icon: Icons.confirmation_number_rounded, label: ticketType == 'reserved' ? 'PNR' : 'UTS', value: ticketType == 'reserved' ? pnrNumber : utsNumber),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetaChip(icon: Icons.directions_railway_rounded, label: 'TRAIN', value: "${coach.toString().toUpperCase()} • $trainNumber"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (weight != null)
                Expanded(
                  child: _MetaChip(icon: Icons.monitor_weight_outlined, label: 'WEIGHT', value: '$weight kg'),
                ),
              if (weight != null) const SizedBox(width: 8),
              Expanded(
                child: _MetaChip(icon: Icons.currency_rupee_rounded, label: 'FARE', value: fare),
              ),
            ],
          ),
          if (desc.isNotEmpty && desc != 'N/A') ...[const SizedBox(height: 10), _NoteRow(note: desc, primary: primary)],
        ],
      ),
    );
  }
}

class _ActiveRouteSection extends StatelessWidget {
  final Booking booking;
  final Color primary;

  const _ActiveRouteSection({required this.booking, required this.primary});

  @override
  Widget build(BuildContext context) {
    final station = booking.pickupDetails?.station?.toString() ?? 'N/A';
    final coach = booking.pickupDetails?.coachNumber?.toString();
    final dest = booking.destination?.toString() ?? 'N/A';
    final weight = booking.pickupDetails?.weightStatus == "verified" ? booking.pickupDetails?.weight?.toString() : booking.pickupDetails?.originalWeight?.toString();
    final desc = booking.pickupDetails?.description?.toString() ?? '';
    final pnrNumber = booking.pickupDetails?.pnrNumber?.toString() ?? 'N/A';
    final utsNumber = booking.pickupDetails?.utsNumber?.toString() ?? 'N/A';
    final trainNumber = booking.pickupDetails?.trainNumber?.toString() ?? 'N/A';
    final ticketType = booking.pickupDetails?.ticketType?.toString() ?? 'N/A';
    final fare = booking.fare?.baseFare?.toString() ?? '—';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _kSlate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kSlate200, width: 0.9),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteLine(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RouteStop(label: 'PICKUP', value: station, labelColor: const Color(0xFF16A34A)),
                      const SizedBox(height: 20),
                      _RouteStop(label: 'DESTINATION', value: dest, labelColor: const Color(0xFFDC2626)),
                    ],
                  ),
                ),
                if (ticketType.isNotEmpty) ...[const SizedBox(width: 10), _CoachTag(coach: ticketType.capitalizeFirst.toString())],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetaChip(icon: Icons.confirmation_number_rounded, label: ticketType == 'reserved' ? 'PNR' : 'UTS', value: ticketType == 'reserved' ? pnrNumber : utsNumber),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetaChip(icon: Icons.directions_railway_rounded, label: 'TRAIN', value: "${coach.toString().toUpperCase()} • $trainNumber"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (weight != null)
                Expanded(
                  child: _MetaChip(icon: Icons.monitor_weight_outlined, label: 'WEIGHT', value: '$weight kg'),
                ),
              if (weight != null) const SizedBox(width: 8),
              Expanded(
                child: _MetaChip(icon: Icons.currency_rupee_rounded, label: 'FARE', value: fare),
              ),
            ],
          ),
          if (desc.isNotEmpty && desc != 'N/A') ...[const SizedBox(height: 10), _NoteRow(note: desc, primary: primary)],
          if (booking.passengerId != null) ...[_buildDivider(), _buildCoolieSection(booking.passengerId!, context)],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
      child: Row(
        children: List.generate(50, (i) => Expanded(child: Container(height: 1, color: i.isEven ? const Color(0xFFE2E8F0) : Colors.transparent))),
      ),
    );
  }

  Widget _buildCoolieSection(PassengerId passenger, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 1.6),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: ClipOval(
              child: passenger.image.isNotEmpty
                  ? GestureDetector(
                      onTap: () => helper.imageShow(uri: NetworkConstants.baseUrl + passenger.image, context: context),
                      child: Image.network(
                        NetworkConstants.baseUrl + passenger.image.toString(),
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null ? child : _AvatarFallback(),
                        errorBuilder: (_, _, _) => _AvatarFallback(),
                      ),
                    )
                  : Center(
                      child: Text(
                        passenger.name.isNotEmpty ? passenger.name[0].toUpperCase() : 'U',
                        style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Constants.instance.primary),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Connected Passenger",
                  style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  passenger.name.toString().capitalizeFirst.toString(),
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1A202C)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => helper.makePhoneCall(passenger.mobileNo),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: const Color(0xFF16A34A).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 3))],
              ),
              child: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 3),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFBBF7D0), width: 2.5),
          ),
        ),
        ...List.generate(4, (_) => Container(margin: const EdgeInsets.symmetric(vertical: 2), width: 1.5, height: 5, color: const Color(0xFFE2E8F0))),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFECACA), width: 2.5),
          ),
        ),
      ],
    );
  }
}

class _RouteStop extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;

  const _RouteStop({required this.label, required this.value, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: labelColor, letterSpacing: 0.8),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _kSlate800),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _CoachTag extends StatelessWidget {
  final String coach;

  const _CoachTag({required this.coach});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kSlate200, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.train_rounded, size: 13, color: _kSlate400),
          const SizedBox(width: 4),
          Text(
            coach,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _kSlate600),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: _kSlate50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kSlate200, width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _kSlate400),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 9, color: _kSlate400, letterSpacing: 0.6)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
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
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _kSlate600),
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
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: primary.withOpacity(0.38), blurRadius: 12, offset: const Offset(0, 2))],
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
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: _kWhite),
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

class _ActiveJobCard extends StatefulWidget {
  final HomeCtrl controller;
  final Booking booking;
  final Color primary;

  const _ActiveJobCard({required this.controller, required this.booking, required this.primary});

  @override
  State<_ActiveJobCard> createState() => _ActiveJobCardState();
}

class _ActiveJobCardState extends State<_ActiveJobCard> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    final pickupTimeRaw = widget.booking.timestamp?.pickupTime?.toString() ?? '';
    if (pickupTimeRaw.isNotEmpty) {
      try {
        DateTime pickupTime = DateTime.parse(pickupTimeRaw);
        if (pickupTime.isUtc || pickupTimeRaw.endsWith('Z')) {
          pickupTime = pickupTime.toLocal();
        }
        _elapsed = DateTime.now().difference(pickupTime);
        if (_elapsed.isNegative) _elapsed = Duration.zero;
      } catch (_) {
        _elapsed = Duration.zero;
      }
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isInProgress = widget.controller.checkStatuss.value.toLowerCase() == 'in-progress';
      final headerColor = isInProgress ? _kSuccess : widget.primary;
      final isPending = ["pending", "accepted", "rejected"].contains(widget.controller.checkStatuss.value.toLowerCase());
      return Container(
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: headerColor.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            _ActiveHeader(isInProgress: isInProgress, headerColor: headerColor, formattedTime: isInProgress ? _formattedTime : null),
            _ActiveRouteSection(booking: widget.booking, primary: widget.primary),
            _ActiveCTAButton(controller: widget.controller, booking: widget.booking, isInProgress: isInProgress, primary: widget.primary),
            if (isPending && widget.booking.allowCancel == true) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: _buildCancelButton()),
          ],
        ),
      );
    });
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showCancelDialog(),
        icon: const Icon(Icons.cancel_outlined, size: 17),
        label: Text("Cancel Booking", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Constants.instance.primary,
          side: BorderSide(color: Constants.instance.primary.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Constants.instance.primary.withOpacity(0.03),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              "Cancel Booking?",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1A202C)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to cancel this booking?", style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B), height: 1.5)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This action cannot be undone.",
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF92400E), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.close(1),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Keep It", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: widget.controller.isLoading.value ? null : () async => await widget.controller.cancelBooking(widget.booking.id.toString(), true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: widget.controller.isLoading.value
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                          : Text(
                              "Yes, Cancel",
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveHeader extends StatelessWidget {
  final bool isInProgress;
  final Color headerColor;
  final String? formattedTime;

  const _ActiveHeader({required this.isInProgress, required this.headerColor, this.formattedTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isInProgress ? 'Job In Progress' : 'Job Accepted',
                  style: GoogleFonts.poppins(color: _kWhite, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(isInProgress ? 'Live time elapsed' : 'Verify OTP to begin the job', style: GoogleFonts.poppins(color: _kWhite.withOpacity(0.72), fontSize: 11)),
              ],
            ),
          ),
          if (isInProgress && formattedTime != null) _LiveTimerBadge(time: formattedTime!),
        ],
      ),
    );
  }
}

class _LiveTimerBadge extends StatelessWidget {
  final String time;

  const _LiveTimerBadge({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(),
          const SizedBox(width: 6),
          Text(
            time,
            style: GoogleFonts.poppins(color: _kSuccess, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _kSuccess.withOpacity(_anim.value)),
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
              ? () => _showCompleteConfirmDialog(context, controller, booking)
              : () => controller.verifyBooking(notificationAction: "weight_disputed"),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 58,
            width: double.infinity,
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: btnColor.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 1))],
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
                      Text(
                        isInProgress ? 'Complete Booking' : 'Verify OTP to Start',
                        style: GoogleFonts.poppins(fontSize: 15, letterSpacing: .5, fontWeight: FontWeight.w600, color: _kWhite),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showCompleteConfirmDialog(BuildContext context, HomeCtrl controller, Booking booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), shape: BoxShape.circle),
              child: const Icon(Icons.task_alt_rounded, color: Color(0xFF16A34A), size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Complete Service?',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              'Confirm that you have successfully delivered the luggage to the destination. This action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8), height: 1.6),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.completeService(booking.id?.toString());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Yes, Complete',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFC60000),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 42),
    );
  }
}
