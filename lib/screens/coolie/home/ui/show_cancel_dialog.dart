import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String?> showCancelBookingDialog(BuildContext context) async {
  final reasons = ['Passenger not responding', 'I am not feeling well', 'Emergency came up', 'Other'];
  String? selectedReason;
  final otherController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool showReasonError = false;
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFCEBEB),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        border: Border(bottom: BorderSide(color: Color(0xFFF7C1C1), width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: Color(0xFFF09595), shape: BoxShape.circle),
                            child: const Icon(Icons.cancel_rounded, color: Color(0xFF791F1F), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cancel booking?',
                                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF791F1F)),
                              ),
                              Text('This action cannot be undone', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFA32D2D))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SELECT REASON *',
                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF888780), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 10),
                          ...reasons.map((reason) {
                            final isSelected = selectedReason == reason;
                            return GestureDetector(
                              onTap: () => setState(() {
                                selectedReason = reason;
                                showReasonError = false;
                              }),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFCEBEB) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSelected ? const Color(0xFFE24B4A) : const Color(0xFFE2E8F0), width: isSelected ? 1 : 0.5),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? const Color(0xFFE24B4A) : Colors.transparent,
                                        border: Border.all(color: isSelected ? const Color(0xFFE24B4A) : const Color(0xFFB4B2A9), width: 1.5),
                                      ),
                                      child: isSelected ? const Icon(Icons.check, size: 11, color: Colors.white) : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      reason,
                                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF791F1F) : const Color(0xFF1A202C)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          if (selectedReason == 'Other') ...[
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: otherController,
                              maxLines: 3,
                              style: GoogleFonts.poppins(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Describe your reason...',
                                hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF888780)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe your reason' : null,
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (showReasonError) ...[
                            Text('Please select a reason before cancelling.', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFE24B4A))),
                            const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    'Don\'t Cancel',
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF1A202C)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (selectedReason == null) {
                                      setState(() => showReasonError = true);
                                      return;
                                    }
                                    if (selectedReason == 'Other') {
                                      if (!formKey.currentState!.validate()) return;
                                    }
                                    final finalReason = selectedReason == 'Other' ? otherController.text.trim() : selectedReason!;
                                    Navigator.pop(context, finalReason);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE24B4A),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    'Yes, cancel',
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
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
            ),
          );
        },
      );
    },
  );
}
