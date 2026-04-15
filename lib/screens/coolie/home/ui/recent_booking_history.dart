import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:license_sahayak/models/history_model.dart';
import 'package:license_sahayak/screens/coolie/booking_history/booking_history.dart';
import 'package:license_sahayak/screens/coolie/home/home_ctrl.dart';
import 'package:license_sahayak/screens/coolie/home/ui/booking_details.dart';

class RecentBookingHistory extends StatefulWidget {
  final HomeCtrl controller;

  const RecentBookingHistory({super.key, required this.controller});

  @override
  State<RecentBookingHistory> createState() => _RecentBookingHistoryState();
}

class _RecentBookingHistoryState extends State<RecentBookingHistory> {
  bool _isLoading = false;
  List<GetAllBookings> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    setState(() => _isLoading = true);
    try {
      final res = await widget.controller.authRepo.getHistory(page: 1, limit: 5);
      if (res != null) {
        final Map<String, dynamic> bookingsData = res['bookings'];
        final List<dynamic> docs = bookingsData['docs'];
        final newBookings = docs.map((e) => GetAllBookings.fromJson(e)).toList();
        setState(() => _recent = newBookings);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B), letterSpacing: 0.6),
        ),
        const SizedBox(height: 10),
        if (_isLoading)
          const _HistoryShimmer()
        else if (_recent.isEmpty)
          const _EmptyHistory()
        else
          Column(
            children: [
              ..._recent.asMap().entries.map((e) => _RecentHistoryTile(booking: e.value, index: e.key)),
              const SizedBox(height: 4),
              _ViewAllButton(),
            ],
          ),
      ],
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const BookingHistory()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
            const SizedBox(width: 7),
            Text(
              'View full history',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentHistoryTile extends StatelessWidget {
  final GetAllBookings booking;
  final int index;

  const _RecentHistoryTile({required this.booking, required this.index});

  _StatusStyle _style(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _StatusStyle(icon: Icons.check_circle_outline_rounded, fg: const Color(0xFF16A34A), bg: const Color(0xFFEAFFF1), label: 'Completed');
      case 'accepted':
        return _StatusStyle(icon: Icons.thumb_up_alt_outlined, fg: const Color(0xFF2563EB), bg: const Color(0xFFEFF6FF), label: 'Accepted');
      case 'pending':
        return _StatusStyle(icon: Icons.hourglass_top_rounded, fg: const Color(0xFFEA580C), bg: const Color(0xFFFFF7ED), label: 'Pending');
      case 'cancelled':
        return _StatusStyle(icon: Icons.cancel_outlined, fg: const Color(0xFFDC2626), bg: const Color(0xFFFFF1F1), label: 'Cancelled');
      default:
        return _StatusStyle(icon: Icons.circle_outlined, fg: const Color(0xFF94A3B8), bg: const Color(0xFFF1F5F9), label: status);
    }
  }

  String _formatDate(String? raw) {
    if (raw == null) return 'N/A';
    try {
      return DateFormat('dd MMM, hh:mm a').format(DateTime.parse(raw));
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = booking.status?.toString() ?? '';
    final s = _style(status);
    final station = booking.pickupDetails?.station?.toString() ?? 'N/A';
    final coachNo = booking.pickupDetails?.coachNumber?.toString() ?? 'N/A';
    final weight = booking.pickupDetails?.weight?.toString();
    final dest = booking.destination?.toString() ?? 'N/A';
    final fare = booking.fare?.baseFare?.toString() ?? '—';
    final bookedAt = _formatDate(booking.timestamp?.bookedAt?.toString());
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 180 + index * 50),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (ctx, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 8 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onTap: () => BookingDetailsSheet.show(context, booking: booking),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(s.icon, color: s.fg, size: 16),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 10.0,
                            children: [
                              Flexible(
                                child: Text(
                                  'Pickup $station',
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.arrow_forward_rounded, size: 11, color: const Color(0xFFCBD5E1)),
                              Flexible(
                                child: Text(
                                  'Drop $dest',
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            spacing: 4.0,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFFCBD5E1)),
                                    const SizedBox(width: 4),
                                    Text(bookedAt, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  s.label,
                                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: s.fg),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.currency_rupee_rounded, size: 13, color: Color(0xFF1E293B)),
                                  Text(
                                    fare,
                                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _FooterChip(icon: Icons.train_rounded, label: 'Coach $coachNo'),
                    if (weight != null) ...[const SizedBox(width: 12), _FooterChip(icon: Icons.monitor_weight_outlined, label: '$weight kg')],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FooterChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFFCBD5E1)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
      ],
    );
  }
}

class _StatusStyle {
  final IconData icon;
  final Color fg;
  final Color bg;
  final String label;

  const _StatusStyle({required this.icon, required this.fg, required this.bg, required this.label});
}

class _HistoryShimmer extends StatefulWidget {
  const _HistoryShimmer();

  @override
  State<_HistoryShimmer> createState() => _HistoryShimmerState();
}

class _HistoryShimmerState extends State<_HistoryShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
      builder: (_, _) {
        final op = 0.35 + _anim.value * 0.35;
        return Column(
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              ),
              child: Row(
                children: [
                  _ShimBox(w: 40, h: 40, r: 10, op: op),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimBox(w: double.infinity, h: 13, r: 5, op: op),
                        const SizedBox(height: 7),
                        _ShimBox(w: 100, h: 11, r: 5, op: op),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ShimBox(w: 48, h: 15, r: 5, op: op),
                      const SizedBox(height: 6),
                      _ShimBox(w: 58, h: 18, r: 20, op: op),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShimBox extends StatelessWidget {
  final double w, h, r, op;

  const _ShimBox({required this.w, required this.h, required this.r, required this.op});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: op,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(r)),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.history_rounded, size: 22, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 10),
          Text(
            'No recent activity',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 3),
          Text('Completed jobs will appear here', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFCBD5E1))),
        ],
      ),
    );
  }
}
