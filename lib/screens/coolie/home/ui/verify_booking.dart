import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

const _kSlate400 = Color(0xFF94A3B8);
const _kSlate900 = Color(0xFF0F172A);

void otpDialog({required TextEditingController verificationCodeController, required Future<bool> Function() onVerify}) {
  Get.dialog(barrierDismissible: false, _OtpFlowDialog(verificationCodeController: verificationCodeController, onVerify: onVerify));
}

class _OtpFlowDialog extends StatefulWidget {
  final TextEditingController verificationCodeController;
  final Future<bool> Function() onVerify;

  const _OtpFlowDialog({required this.verificationCodeController, required this.onVerify});

  @override
  State<_OtpFlowDialog> createState() => _OtpFlowDialogState();
}

class _OtpFlowDialogState extends State<_OtpFlowDialog> with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  late AnimationController _anim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (widget.verificationCodeController.text.length < 4) return;
    try {
      setState(() => _isLoading = true);
      final success = await widget.onVerify();
      if (!success) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 16))],
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                child: _OtpStep(key: const ValueKey('otp'), controller: widget.verificationCodeController, isLoading: _isLoading, onVerify: _handleVerify),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onVerify;

  const _OtpStep({super.key, required this.controller, required this.isLoading, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Passenger OTP',
            style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: _kSlate900),
          ),
          Text('Ask passenger for the 4-digit code', style: GoogleFonts.poppins(fontSize: 11, color: _kSlate400)),
          const SizedBox(height: 28),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: Constants.instance.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.lock_open_rounded, size: 32, color: Constants.instance.primary),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: MaterialPinField(
              length: 4,
              onChanged: (value) {
                controller.text = value;
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enableHapticFeedback: true,
              hapticFeedbackType: HapticFeedbackType.selection,
              theme: MaterialPinTheme(
                cellSize: const Size(56, 56),
                shape: MaterialPinShape.filled,
                borderRadius: BorderRadius.circular(12),
                borderWidth: 2,
                cursorHeight: 25,
                focusedFillColor: Constants.instance.primary.withOpacity(0.05),
                filledFillColor: Constants.instance.primary.withOpacity(0.1),
              ),
              autoFocus: true,
            ),
          ),
          const SizedBox(height: 28),
          _FilledButton(label: 'Verify & Start Job', icon: Icons.verified_rounded, color: Constants.instance.primary, isLoading: isLoading, fullWidth: true, height: 54, onTap: onVerify),
        ],
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final VoidCallback onTap;

  const _FilledButton({required this.label, required this.icon, required this.color, required this.onTap, this.isLoading = false, this.fullWidth = false, this.height = 48});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: isLoading ? color.withOpacity(0.6) : color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.30), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
