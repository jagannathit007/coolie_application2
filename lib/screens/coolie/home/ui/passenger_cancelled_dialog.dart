import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/utils/app_constants.dart';

class PassengerCancelledDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        title: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), shape: BoxShape.circle),
              child: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              'Booking Cancelled',
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B), letterSpacing: -0.3),
            ),
          ],
        ),
        content: Text(
          'The passenger has cancelled this booking. You are now available for new bookings.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, height: 1.5, color: const Color(0xFF64748B)),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.instance.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text('Okay', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
