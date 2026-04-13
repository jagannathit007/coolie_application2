import 'dart:io';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:license_sahayak/models/get_passenger_coolie_model.dart';
import 'package:license_sahayak/routes/route_name.dart';
import 'package:license_sahayak/screens/coolie/home/ui/profile.dart';
import 'package:license_sahayak/services/app_toasting.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_ctrl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Exit App", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("Do you want to close the application?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey[700])),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: Text("Exit", style: GoogleFonts.poppins(color: Colors.white)),
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
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: Constants.instance.primary,
              elevation: 0,
              title: Text("Coolie Dashboard", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
              foregroundColor: Colors.white,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: IconButton(
                    onPressed: () {
                      controller.fetchUserProfile();
                      controller.getPassengerData();
                      controller.update();
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    tooltip: 'Refresh',
                  ),
                ),
              ],
            ),
            drawer: _buildModernDrawer(controller),
            body: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchUserProfile();
                    await controller.getPassengerData();
                    await controller.checkStatus();
                    controller.update();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeaderSection(controller), const SizedBox(height: 24), _buildBookingListSection(context, controller)]),
                  ),
                ),
                Obx(() {
                  if (controller.isCheckInLoading.value) {
                    return Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Constants.instance.primary), strokeWidth: 3),
                              const SizedBox(height: 24),
                              Text(
                                controller.checkInStatusMessage.value.isNotEmpty ? controller.checkInStatusMessage.value : 'Processing...',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(HomeCtrl controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Constants.instance.primary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Obx(() {
          final profile = controller.userProfile.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back,", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                profile?.name ?? "Coolie",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildCheckInOutButtons(controller),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCheckInOutButtons(HomeCtrl controller) {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: controller.isCheckedIn.value ? [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)] : [Constants.instance.apple, Constants.instance.apple.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton(
                onPressed: controller.isCheckedIn.value ? null : () => controller.performCheckIn(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Check In",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: !controller.isCheckedIn.value
                      ? [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)]
                      : [Constants.instance.primaryLight, Constants.instance.primaryLight.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton(
                onPressed: !controller.isCheckedIn.value ? null : () => controller.checkOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Check Out",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBookingListSection(BuildContext context, HomeCtrl controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt_rounded, size: 24, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                "Today's Bookings",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final booking = controller.passengerDetails.value.booking;
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()),
              );
            }
            if (booking == null) {
              return _buildEmptyState();
            }
            return _buildBookingCard(context, controller, booking);
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No Bookings Available",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text("New bookings will appear here", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, HomeCtrl controller, Booking booking) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Constants.instance.primary, Constants.instance.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[50],
                    child: const Icon(Icons.person_rounded, color: Colors.blue, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.passengerId?.name ?? "Unknown",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            booking.passengerId?.mobileNo ?? "N/A",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _getStatusColor(booking.status ?? "Pending"), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    booking.status ?? "Pending",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Obx(() {
                  if (controller.checkStatuss.value == 'pending') {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.red[400]!, Colors.red[600]!]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  Text(
                                    "Time Remaining",
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(
                                    () => Text(
                                      controller.countdownTime.value,
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You have this much time to accept or decline the request. After that, the request will be expired.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[100]!, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Constants.instance.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Booking Time",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.formatBookingTime(booking.timestamp?.bookedAt.toString()),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.grey[800], fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[100]!, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.currency_rupee, color: Colors.green[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Fare",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "₹${booking.fare?.baseFare ?? "N/A"}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.grey[800], fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[100]!, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.orange[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pickup Location",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Platform ${booking.pickupDetails?.station ?? "N/A"}, Coach ${booking.pickupDetails?.coachNumber ?? "N/A"}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[100]!, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.flag, color: Colors.purple[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Destination",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.destination ?? "N/A",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.blue, Color(0xFF1E88E5)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final phoneNumber = booking.passengerId?.mobileNo ?? "";
                      if (phoneNumber.isNotEmpty) {
                        final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        } else {
                          errorToast('Could not launch phone call');
                        }
                      } else {
                        errorToast('Phone number not available');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.call, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          "Call Passenger",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.checkStatuss.value == 'pending') {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.bookPassenger(controller.passengerDetails.value.booking!.id.toString(), false);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Constants.instance.primaryLight, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              "Decline",
                              style: GoogleFonts.poppins(color: Constants.instance.primaryLight, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Constants.instance.apple, Constants.instance.apple.withOpacity(0.8)]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Constants.instance.apple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                controller.bookPassenger(controller.passengerDetails.value.booking!.id.toString(), true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                "Accept",
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (controller.checkStatuss.value == 'accepted') {
                    return SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.orange, Color(0xFFFF9800)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _showOTPDialog(context, controller);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.dialpad, color: Colors.white, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                "Enter OTP",
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (controller.checkStatuss.value.toLowerCase() == 'in-progress') {
                    return SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.green, Color(0xFF43A047)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            controller.completeService(controller.passengerDetails.value.booking!.id.toString());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                "Complete Service",
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
              ],
            ),
          ),
        ],
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

  void _showOTPDialog(BuildContext context, HomeCtrl controller) {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Enter OTP", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        content: SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: controller.verificationCodeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: "----",
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Constants.instance.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Constants.instance.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.close(1),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Constants.instance.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(color: Constants.instance.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await controller.bookingOPTVerify(controller.passengerDetails.value.booking?.id);
                        controller.verificationCodeController.text = "";
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.instance.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Verify",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
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

  Widget _buildModernDrawer(HomeCtrl controller) {
    return Obx(() {
      final profile = controller.userProfile.value;
      return Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Constants.instance.primary, Constants.instance.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => Profile()),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.grey[200],
                        child: profile?.image?.url.isNotEmpty == true
                            ? ClipOval(child: Image.network("${NetworkConstants.imageURL}${profile!.image!.url}", fit: BoxFit.cover, width: 72, height: 72))
                            : const Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile?.name ?? "Loading...",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(profile?.emailId.isNotEmpty == true ? profile!.emailId : profile?.mobileNo ?? "", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: Icon(Icons.person_outline, color: Constants.instance.primary),
                    title: Text('My Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Get.close(1);
                      Get.to(() => Profile());
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.history, color: Constants.instance.primary),
                    title: Text('Booking History', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Get.close(1);
                      Get.toNamed(RouteName.bookingHistory);
                    },
                  ),
                  const Divider(height: 32),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.red),
                    ),
                    onTap: () => controller.showLogoutDialog(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
