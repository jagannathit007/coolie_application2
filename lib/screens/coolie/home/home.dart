import 'dart:io';
import 'package:license_sahayak/screens/coolie/home/home_ctrl.dart';
import 'package:license_sahayak/screens/coolie/home/ui/booking_req_ui.dart';
import 'package:license_sahayak/screens/coolie/home/ui/home_header_ui.dart';
import 'package:license_sahayak/screens/coolie/home/ui/recent_booking_history.dart';
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
                  child: RefreshIndicator(
                    color: Constants.instance.primary,
                    onRefresh: () async => await controller.initialize(),
                    child: Obx(
                      () => controller.isLoading.value
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
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
