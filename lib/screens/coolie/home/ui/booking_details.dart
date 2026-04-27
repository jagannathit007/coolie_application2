import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:license_sahayak/models/get_passenger_coolie_model.dart';
import 'package:license_sahayak/screens/coolie/home/ui/booking_req_ui.dart';
import 'package:license_sahayak/utils/app_constants.dart';

class BookingDetailsSheet extends StatelessWidget {
  final Booking? booking;
  final Map<String, dynamic>? rawBooking;

  const BookingDetailsSheet._({this.booking, this.rawBooking}) : assert(booking != null || rawBooking != null, 'Provide either booking or rawBooking');

  static void show(BuildContext context, {Booking? booking, Map<String, dynamic>? rawBooking}) {
    assert(booking != null || rawBooking != null, 'Provide either booking or rawBooking');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingDetailsSheet._(booking: booking, rawBooking: rawBooking),
    );
  }

  String get _status => booking?.status?.toString() ?? rawBooking?['status']?.toString() ?? '';

  String get _station => booking?.pickupDetails?.station?.toString() ?? rawBooking?['pickupDetails']?['station']?.toString() ?? 'N/A';

  String get _coach => booking?.pickupDetails?.coachNumber?.toString() ?? rawBooking?['pickupDetails']?['coachNumber']?.toString() ?? 'N/A';

  String get _dest => booking?.destination?.toString() ?? rawBooking?['destination']?.toString() ?? 'N/A';

  String? get _bookedAtRaw => booking?.timestamp?.bookedAt?.toString() ?? rawBooking?['timestamp']?['bookedAt']?.toString();

  String? get _completedAtRaw => booking?.timestamp?.completedAt?.toString() ?? rawBooking?['timestamp']?['completedAt']?.toString();

  String get _pnr => booking?.pickupDetails?.pnrNumber?.toString() ?? rawBooking?['pickupDetails']?['pnrNumber']?.toString() ?? 'N/A';

  String get _uts => booking?.pickupDetails?.utsNumber?.toString() ?? rawBooking?['pickupDetails']?['utsNumber']?.toString() ?? 'N/A';

  String get _trainNumber => booking?.pickupDetails?.trainNumber?.toString() ?? rawBooking?['pickupDetails']?['trainNumber']?.toString() ?? 'N/A';

  String get _ticketType => booking?.pickupDetails?.ticketType?.toString() ?? rawBooking?['pickupDetails']?['ticketType']?.toString() ?? 'N/A';

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      return DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.parse(raw).toUtc().toLocal());
    } catch (_) {
      return 'N/A';
    }
  }

  _StatusStyle get _statusStyle {
    switch (_status.toLowerCase()) {
      case 'completed':
        return _StatusStyle(label: 'Completed', icon: Icons.check_rounded, fg: const Color(0xFF15803D), bg: const Color(0xFFEAFFF1), dot: const Color(0xFF22C55E), dotRing: const Color(0xFFBBF7D0));
      case 'accepted':
        return _StatusStyle(
          label: 'Accepted',
          icon: Icons.thumb_up_alt_outlined,
          fg: const Color(0xFF1D4ED8),
          bg: const Color(0xFFEEF4FF),
          dot: const Color(0xFF3B82F6),
          dotRing: const Color(0xFFBFDBFE),
        );
      case 'pending':
        return _StatusStyle(
          label: 'Pending',
          icon: Icons.hourglass_top_rounded,
          fg: const Color(0xFFC2410C),
          bg: const Color(0xFFFFF7ED),
          dot: const Color(0xFFF97316),
          dotRing: const Color(0xFFFED7AA),
        );
      case 'cancelled':
        return _StatusStyle(label: 'Cancelled', icon: Icons.cancel_outlined, fg: const Color(0xFFB91C1C), bg: const Color(0xFFFFF1F1), dot: const Color(0xFFEF4444), dotRing: const Color(0xFFFECACA));
      default:
        return _StatusStyle(
          label: _status.isEmpty ? 'Unknown' : _status,
          icon: Icons.circle_outlined,
          fg: const Color(0xFF64748B),
          bg: const Color(0xFFF1F5F9),
          dot: const Color(0xFF94A3B8),
          dotRing: const Color(0xFFCBD5E1),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle;
    final primary = Constants.instance.primary;
    final bookedAt = _formatDate(_bookedAtRaw);
    final completedAt = _completedAtRaw != null ? _formatDate(_completedAtRaw) : null;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: primary.withOpacity(0.10), borderRadius: BorderRadius.circular(11)),
                    child: Icon(Icons.receipt_long_rounded, color: primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip details',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                        ),
                        Text(bookedAt, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  _StatusPill(s: s),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _SectionLabel(label: 'Journey', primary: primary),
                  _InfoCard(
                    rows: [
                      _InfoRow(icon: Icons.trip_origin_rounded, label: 'Pickup station', value: _station, primary: primary),
                      _InfoRow(icon: Icons.location_on_rounded, label: 'Destination', value: _dest, primary: primary),
                      _InfoRow(icon: Icons.train_rounded, label: 'Coach number', value: _coach, primary: primary),
                      _InfoRow(icon: Icons.confirmation_number_rounded, label: '${_ticketType == 'reserved' ? 'PNR' : 'UTS'} number', value: _ticketType == 'reserved' ? _pnr : _uts, primary: primary),
                      _InfoRow(icon: Icons.confirmation_number_rounded, label: 'Ticket type', value: _ticketType.capitalizeFirst.toString(), primary: primary),
                      _InfoRow(icon: Icons.directions_railway_rounded, label: 'Train number', value: _trainNumber, primary: primary),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(label: 'Payment', primary: primary),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PackageSelection(packages: booking?.pickupDetails?.packages ?? []),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(label: 'Timeline', primary: primary),
                  _InfoCard(
                    rows: [
                      _InfoRow(icon: Icons.schedule_rounded, label: 'Booked at', value: bookedAt, primary: primary),
                      if (completedAt != null)
                        _InfoRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Completed at',
                          value: completedAt,
                          primary: primary,
                          iconColor: const Color(0xFF16A34A),
                          iconBg: const Color(0xFFEAFFF1),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Close', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _StatusStyle s;

  const _StatusPill({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 11, color: s.fg),
          const SizedBox(width: 4),
          Text(
            s.label,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: s.fg),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color primary;

  const _SectionLabel({required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
        child: Column(children: rows),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color primary;
  final Color? iconColor;
  final Color? iconBg;

  const _InfoRow({required this.icon, required this.label, required this.value, required this.primary, this.iconColor, this.iconBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: iconBg ?? primary.withOpacity(0.08), borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, size: 14, color: iconColor ?? primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8))),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final String label;
  final IconData icon;
  final Color fg, bg, dot, dotRing;

  const _StatusStyle({required this.label, required this.icon, required this.fg, required this.bg, required this.dot, required this.dotRing});
}
