import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_constants.dart';
import 'otp_verify_ctrl.dart';

class OtpVerification extends StatelessWidget {
  const OtpVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GetBuilder<OtpVerifyCtrl>(
      init: OtpVerifyCtrl(),
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF5F6FA),
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Stack(
              children: [
                Positioned(top: 0, left: 0, right: 0, height: size.height * 0.4, child: _buildTopPanel(size)),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top),
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.11),
                          _buildHeroSection(size),
                          SizedBox(height: size.height * 0.09),
                          _buildOtpCard(context, controller),
                          const SizedBox(height: 28),
                          _buildResendRow(controller),
                          const SizedBox(height: 12),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: SafeArea(
                              top: false,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 5),
                                    child: const Text(
                                      'Back to Login',
                                      style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopPanel(Size size) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Constants.instance.primary, Color.lerp(Constants.instance.primary, Colors.black, 0.18)!]),
          ),
        ),
        Positioned(
          top: -60,
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)),
          ),
        ),
        Positioned(
          bottom: 20,
          left: -40,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
          ),
        ),
        Positioned(
          top: 40,
          left: 30,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)),
          ),
        ),
        Positioned(
          bottom: -1,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 48, color: const Color(0xFFF5F6FA)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(Size size) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFC60000), Color(0xFFFF4B4B)]),
                boxShadow: [BoxShadow(color: const Color(0xFFC60000).withOpacity(0.30), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: ClipOval(child: Image.asset("assets/logo.png", height: 48, width: 48, fit: BoxFit.contain)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'OTP Verification',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
        ),
        const SizedBox(height: 4),
        Text(
          'Verify your mobile number to continue',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildOtpCard(BuildContext context, OtpVerifyCtrl controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 32, offset: const Offset(0, 8))],
        ),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter OTP',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            Text(
              'A 4-digit code has been sent to your mobile number',
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 28),
            _OtpInputRow(controller: controller),
            const SizedBox(height: 32),
            Obx(
              () => AnimatedScale(
                scale: controller.isLoading.value ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: GestureDetector(
                  onTap: controller.isLoading.value ? null : () async => await controller.verifyOtp(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    decoration: BoxDecoration(
                      color: controller.isLoading.value ? Constants.instance.primary.withOpacity(0.65) : Constants.instance.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: controller.isLoading.value ? [] : [BoxShadow(color: Constants.instance.primary.withOpacity(0.38), blurRadius: 18, offset: const Offset(0, 7))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (controller.isLoading.value) ...[
                          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          const SizedBox(width: 10),
                          Text(
                            'Verifying...',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ] else ...[
                          Text(
                            'Verify OTP',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.verified_rounded, size: 18, color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResendRow(OtpVerifyCtrl controller) {
    return Obx(() {
      final canResend = controller.isResendEnabled.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(canResend ? "Didn't receive the OTP?  " : 'Resend OTP in ${controller.countdown.value}s  ', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8))),
          if (canResend)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.resendOtp,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    'Resend OTP',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Constants.instance.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: Constants.instance.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _OtpInputRow extends StatefulWidget {
  final OtpVerifyCtrl controller;

  const _OtpInputRow({required this.controller});

  @override
  State<_OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<_OtpInputRow> {
  final int _length = 4;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final otp = _controllers.map((c) => c.text).join();
    widget.controller.verificationCodeController.text = otp;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_length, (i) {
        return _OtpBox(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          onChanged: (v) => _onChanged(v, i),
          onTap: () => _controllers[i].selection = TextSelection.fromPosition(TextPosition(offset: _controllers[i].text.length)),
        );
      }),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;

  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged, required this.onTap});

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: _isFocused ? Constants.instance.primary.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _isFocused
            ? [BoxShadow(color: Constants.instance.primary.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: TextField(
        obscureText: true,
        obscuringCharacter: "•",
        controller: widget.controller,
        focusNode: widget.focusNode,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        cursorHeight: 25,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
        decoration: const InputDecoration(counterText: ''),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.5, size.width * 0.5, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.75, 0, size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
