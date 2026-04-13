import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:license_sahayak/screens/coolie/booking_history/booking_history.dart';
import 'package:license_sahayak/screens/coolie/home/home_ctrl.dart';
import 'package:license_sahayak/utils/app_constants.dart';

const _kSlate100 = Color(0xFFF1F5F9);
const _kSlate200 = Color(0xFFE2E8F0);
const _kSlate400 = Color(0xFF94A3B8);
const _kSlate900 = Color(0xFF0F172A);

class RecentBookingHistory extends StatefulWidget {
  final HomeCtrl controller;

  const RecentBookingHistory({super.key, required this.controller});

  @override
  State<RecentBookingHistory> createState() => _RecentBookingHistoryState();
}

class _RecentBookingHistoryState extends State<RecentBookingHistory> {
  bool _isLoading = false;

  List<dynamic> _recent = [];

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
        final docs = (res['bookings']['docs'] as List?) ?? [];
        setState(() => _recent = docs);
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
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kSlate900),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          _HistoryShimmer()
        else if (_recent.isEmpty)
          _EmptyHistory()
        else
          Column(
            children: [
              ..._recent.asMap().entries.map((e) => _RecentHistoryTile(booking: e.value, index: e.key)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => Get.to(() => const BookingHistory()),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kSlate200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 16, color: Constants.instance.primary),
                      const SizedBox(width: 8),
                      Text(
                        'View Full History',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Constants.instance.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _RecentHistoryTile extends StatelessWidget {
  final dynamic booking;
  final int index;

  const _RecentHistoryTile({required this.booking, required this.index});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF22C55E);
      case 'accepted':
        return const Color(0xFF3B82F6);
      case 'pending':
        return const Color(0xFFF97316);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return _kSlate400;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.task_alt_rounded;
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
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
    final status = booking['status']?.toString() ?? '';
    final color = _statusColor(status);
    final station = booking['pickupDetails']?['station']?.toString() ?? 'N/A';
    final dest = booking['destination']?.toString() ?? 'N/A';
    final fare = booking['fare']?['baseFare']?.toString() ?? '—';
    final bookedAt = _formatDate(booking['timestamp']?['bookedAt']?.toString());
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + index * 60),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (ctx, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(13)),
                child: Icon(_statusIcon(status), color: color, size: 20),
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
                            "PICKUP $station",
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _kSlate900),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 12, color: _kSlate400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "DROP $dest",
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _kSlate900),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 11, color: _kSlate400),
                        const SizedBox(width: 4),
                        Text(bookedAt, style: GoogleFonts.poppins(fontSize: 11, color: _kSlate400)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.currency_rupee_rounded, size: 13, color: _kSlate900),
                      Text(
                        fare,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: _kSlate900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      status.isNotEmpty ? status[0].toUpperCase() + status.substring(1).toLowerCase() : '—',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryShimmer extends StatefulWidget {
  @override
  State<_HistoryShimmer> createState() => _HistoryShimmerState();
}

class _HistoryShimmerState extends State<_HistoryShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
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
        final opacity = 0.4 + _anim.value * 0.4;
        return Column(
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  _ShimmerBox(width: 44, height: 44, radius: 13, opacity: opacity),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(width: double.infinity, height: 13, radius: 6, opacity: opacity),
                        const SizedBox(height: 8),
                        _ShimmerBox(width: 120, height: 11, radius: 6, opacity: opacity),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ShimmerBox(width: 50, height: 15, radius: 6, opacity: opacity),
                      const SizedBox(height: 6),
                      _ShimmerBox(width: 60, height: 18, radius: 20, opacity: opacity),
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

class _ShimmerBox extends StatelessWidget {
  final double width, height, radius, opacity;

  const _ShimmerBox({required this.width, required this.height, required this.radius, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: _kSlate100, borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: _kSlate100, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.history_rounded, size: 28, color: _kSlate200),
          ),
          const SizedBox(height: 12),
          Text(
            'No recent activity',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _kSlate400),
          ),
          const SizedBox(height: 4),
          Text('Completed jobs will appear here', style: GoogleFonts.poppins(fontSize: 12, color: _kSlate200)),
        ],
      ),
    );
  }
}
