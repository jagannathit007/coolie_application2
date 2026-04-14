import 'package:license_sahayak/models/history_model.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_history_ctrl.dart';

class BookingHistory extends StatelessWidget {
  const BookingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingHistoryCtrl>(
      init: BookingHistoryCtrl(),
      builder: (controller) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            body: Column(
              children: [
                _buildAppBarWithStats(controller),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.bookings.isEmpty) {
                      return _buildShimmerLoading();
                    }
                    if (controller.bookings.isEmpty) {
                      return _buildEmptyState();
                    }
                    return RefreshIndicator(
                      color: Constants.instance.primary,
                      onRefresh: () => controller.refreshHistory(),
                      child: ListView.builder(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: controller.bookings.length + (controller.hasMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.bookings.length && controller.hasMore.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5))),
                            );
                          }
                          final booking = controller.bookings[index];
                          return _BookingCard(booking: booking, controller: controller, index: index);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarWithStats(BookingHistoryCtrl controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Constants.instance.primary, Constants.instance.primary.withBlue((Constants.instance.primary.blue + 40).clamp(0, 255))],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Constants.instance.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  BackButton(color: Colors.white),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Booking History",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white, letterSpacing: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 15),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(icon: Icons.confirmation_num_outlined, label: "Total Trips", value: controller.bookings.length.toString(), iconColor: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(icon: Icons.account_balance_wallet_outlined, label: "Total Spent", value: "₹${controller.calculateTotalSpent()}", iconColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), itemCount: 5, itemBuilder: (_, _) => const _ShimmerCard());
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            "No Bookings Yet",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text("Your completed trips will appear here", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _StatCard({required this.icon, required this.label, required this.value, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final GetAllBookings booking;
  final BookingHistoryCtrl controller;
  final int index;

  const _BookingCard({required this.booking, required this.controller, required this.index});

  _StatusStyle get _status {
    switch (booking.status.toString().toLowerCase()) {
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
          label: booking.status.toString(),
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
    final s = _status;
    final station = booking.pickupDetails?.station?.toString() ?? 'N/A';
    final coach = booking.pickupDetails?.coachNumber?.toString();
    final dest = booking.destination?.toString() ?? 'N/A';
    final weight = booking.pickupDetails?.weight?.toString();
    final fare = booking.fare?.baseFare?.toString() ?? '—';
    final bookedAt = controller.formatDate(booking.timestamp?.bookedAt?.toString() ?? '');
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 220 + (index * 40).clamp(0, 360)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onTap: () => _showDetails(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                      ),
                      child: Text(
                        '#${(index + 1).toString().padLeft(3, '0')}',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B), letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFFCBD5E1)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        bookedAt,
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusPill(s: s),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RouteLine(s: s),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _RouteStop(label: 'PICKUP', value: coach != null ? 'Platform $station  ·  Coach $coach' : 'Platform $station', labelColor: const Color(0xFF16A34A)),
                              const SizedBox(height: 18),
                              _RouteStop(label: 'DESTINATION', value: dest, labelColor: const Color(0xFFDC2626)),
                            ],
                          ),
                        ),
                        if (coach != null) ...[const SizedBox(width: 10), _CoachTag(coach: coach)],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (weight != null)
                          Expanded(
                            child: _MetaChip(icon: Icons.monitor_weight_outlined, label: 'WEIGHT', value: '$weight kg'),
                          ),
                        if (weight != null) const SizedBox(width: 8),
                        Expanded(
                          child: _MetaChip(icon: Icons.access_time_rounded, label: 'BOOKED AT', value: _timeOnly(booking.timestamp?.bookedAt?.toString())),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
                      ),
                      child: Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '₹',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                                ),
                                TextSpan(
                                  text: fare,
                                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B), height: 1),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showDetails(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(color: Constants.instance.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility_rounded, size: 14, color: Constants.instance.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'View details',
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Constants.instance.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeOnly(String? raw) {
    if (raw == null) return 'N/A';
    try {
      final dt = DateTime.parse(raw);
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } catch (_) {
      return 'N/A';
    }
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingDetailsSheet(booking: booking, controller: controller),
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

class _RouteLine extends StatelessWidget {
  final _StatusStyle s;

  const _RouteLine({required this.s});

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
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.train_rounded, size: 13, color: Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Text(
            coach,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
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
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF94A3B8), letterSpacing: 0.6)),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingDetailsSheet extends StatelessWidget {
  final dynamic booking;
  final BookingHistoryCtrl controller;

  const _BookingDetailsSheet({required this.booking, required this.controller});

  _StatusStyle get _status {
    switch (booking.status.toString().toLowerCase()) {
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
          label: booking.status.toString(),
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
    final s = _status;
    final primary = Constants.instance.primary;
    final station = booking.pickupDetails?.station?.toString() ?? 'N/A';
    final coach = booking.pickupDetails?.coachNumber?.toString() ?? 'N/A';
    final dest = booking.destination?.toString() ?? 'N/A';
    final weight = booking.pickupDetails?.weight?.toString() ?? 'N/A';
    final fare = booking.fare?.baseFare?.toString() ?? '—';
    final bookedAt = controller.formatDate(booking.timestamp?.bookedAt?.toString() ?? '');
    final completedAt = booking.timestamp?.completedAt != null ? controller.formatDate(booking.timestamp!.completedAt.toString()) : null;
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
                  _SheetSectionLabel(label: 'Journey', primary: primary),
                  _SheetInfoCard(
                    rows: [
                      _SheetInfoRow(icon: Icons.trip_origin_rounded, label: 'Pickup station', value: 'Platform $station', primary: primary),
                      _SheetInfoRow(icon: Icons.location_on_rounded, label: 'Destination', value: dest, primary: primary),
                      _SheetInfoRow(icon: Icons.train_rounded, label: 'Coach number', value: coach, primary: primary),
                      _SheetInfoRow(icon: Icons.monitor_weight_outlined, label: 'Luggage weight', value: '$weight kg', primary: primary),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SheetSectionLabel(label: 'Payment', primary: primary),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(color: primary.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.account_balance_wallet_rounded, color: primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total fare', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '₹',
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                                    ),
                                    TextSpan(
                                      text: fare,
                                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B), height: 1.1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SheetSectionLabel(label: 'Timeline', primary: primary),
                  _SheetInfoCard(
                    rows: [
                      _SheetInfoRow(icon: Icons.schedule_rounded, label: 'Booked at', value: bookedAt, primary: primary),
                      if (completedAt != null)
                        _SheetInfoRow(
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

class _SheetSectionLabel extends StatelessWidget {
  final String label;
  final Color primary;

  const _SheetSectionLabel({required this.label, required this.primary});

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

class _SheetInfoCard extends StatelessWidget {
  final List<Widget> rows;

  const _SheetInfoCard({required this.rows});

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

class _SheetInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color primary;
  final Color? iconColor;
  final Color? iconBg;

  const _SheetInfoRow({required this.icon, required this.label, required this.value, required this.primary, this.iconColor, this.iconBg});

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
  final Color fg;
  final Color bg;
  final Color dot;
  final Color dotRing;

  const _StatusStyle({required this.label, required this.icon, required this.fg, required this.bg, required this.dot, required this.dotRing});
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _anim = Tween<double>(begin: -1.0, end: 2.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _shimmerBox({double width = double.infinity, double height = 14, double radius = 8}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [(_anim.value - 1).clamp(0.0, 1.0), _anim.value.clamp(0.0, 1.0), (_anim.value + 1).clamp(0.0, 1.0)],
            colors: const [Color(0xFFEEEEEE), Color(0xFFF8F8F8), Color(0xFFEEEEEE)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [_shimmerBox(width: 50, height: 22, radius: 6), const Spacer(), _shimmerBox(width: 80, height: 22, radius: 20)]),
          const SizedBox(height: 20),
          _shimmerBox(width: 180),
          const SizedBox(height: 10),
          _shimmerBox(width: 140),
          const SizedBox(height: 20),
          Row(children: [_shimmerBox(width: 70, height: 28), const Spacer(), _shimmerBox(width: 110, height: 36, radius: 12)]),
        ],
      ),
    );
  }
}
