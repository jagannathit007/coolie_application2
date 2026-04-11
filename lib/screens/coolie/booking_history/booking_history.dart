import 'package:license_sahayak/utils/app_constants.dart';
import 'package:flutter/material.dart';
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
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text("Booking History", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
            backgroundColor: Constants.instance.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              _buildHeaderSection(controller),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.bookings.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.bookings.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: () => controller.refreshHistory(),
                    child: ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: controller.bookings.length + (controller.hasMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.bookings.length && controller.hasMore.value) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final booking = controller.bookings[index];
                        return _buildModernBookingCard(booking, controller, index, context);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BookingHistoryCtrl controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Constants.instance.primary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Obx(() {
          return Row(
            children: [
              Expanded(
                child: _buildStatChip(icon: Icons.check_circle_outline, label: "Completed", value: controller.bookings.length.toString(), color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatChip(icon: Icons.currency_rupee, label: "Total Spent", value: controller.calculateTotalSpent(), color: Colors.amber),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No Booking History",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text("Your completed bookings will appear here", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildModernBookingCard(dynamic booking, BookingHistoryCtrl controller, int index, BuildContext context) {
    final statusColor = _getStatusColor(booking.status.toString());
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.receipt_long, color: statusColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Booking #${index + 1}",
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                          ),
                          Text(controller.formatDate(booking.timestamp!.bookedAt.toString()), style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      booking.status.toString().toUpperCase(),
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.trip_origin, color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pickup", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                            Text(
                              "PlateForm Number ${booking.pickupDetails!.station.toString()}",
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 19),
                    child: Column(
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          width: 2,
                          height: 6,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.location_on, color: Colors.red, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Drop", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                            Text(
                              booking.destination.toString(),
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Fare", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.currency_rupee, size: 18, color: Constants.instance.primary),
                              Text(
                                booking.fare!.baseFare.toString(),
                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Constants.instance.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          _showBookingDetailsBottomSheet(context, booking, controller);
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: Text("Details", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Constants.instance.primary,
                          side: BorderSide(color: Constants.instance.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'accepted':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showBookingDetailsBottomSheet(BuildContext context, booking, BookingHistoryCtrl controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Booking Details",
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection("Journey Information", [
                    _buildDetailRow(Icons.trip_origin, "Pickup", booking.pickupDetails!.station.toString()),
                    _buildDetailRow(Icons.location_on, "Destination", booking.destination.toString()),
                    _buildDetailRow(Icons.train, "Coach", booking.pickupDetails!.coachNumber?.toString() ?? "N/A"),
                  ]),
                  const SizedBox(height: 16),
                  _buildDetailSection("Payment Information", [
                    _buildDetailRow(Icons.currency_rupee, "Base Fare", "₹${booking.fare!.baseFare}"),
                    _buildDetailRow(Icons.check_circle, "Status", booking.status.toString().toUpperCase(), valueColor: _getStatusColor(booking.status.toString())),
                  ]),
                  const SizedBox(height: 16),
                  _buildDetailSection("Time Information", [
                    _buildDetailRow(Icons.access_time, "Booked At", controller.formatDate(booking.timestamp!.bookedAt.toString())),
                    if (booking.timestamp!.completedAt != null) _buildDetailRow(Icons.check_circle_outline, "Completed At", controller.formatDate(booking.timestamp!.completedAt.toString())),
                  ]),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.instance.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Close",
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
