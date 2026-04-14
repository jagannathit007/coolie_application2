import 'package:license_sahayak/screens/auth/sign_ctrl.dart';
import 'package:license_sahayak/services/customs/custom_form_field.dart';
import 'package:license_sahayak/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GetBuilder<SignCtrl>(
      init: SignCtrl(),
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
                          _buildHeroBranding(),
                          SizedBox(height: size.height * 0.05),
                          _buildLoginCard(context, controller),
                          const SizedBox(height: 32),
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

  Widget _buildHeroBranding() {
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
          AppConfig.appName,
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
        ),
        const SizedBox(height: 4),
        Text(
          'Your trusted station porter service',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context, SignCtrl controller) {
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
            _buildRoleToggle(controller),
            const SizedBox(height: 20),
            Obx(
              () => Text(
                controller.isMukadam ? 'Welcome, Mukadam!' : 'Welcome back!',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your mobile number to sign in',
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 24),
            Text(
              'Mobile Number',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            CustomFormField(
              controller: controller.mobileController,
              maxLength: 10,
              hintFontSize: 12,
              hintText: 'Enter your 10-digit number',
              keyboardType: TextInputType.phone,
              borderEnabled: true,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\+91')), FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
              prefix: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Constants.instance.primary.withOpacity(0.09), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '+91',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Constants.instance.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your mobile number';
                }
                if (!value.isPhoneNumber) {
                  return 'Enter a valid 10-digit number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Obx(
              () => AnimatedScale(
                scale: controller.isLoading.value ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: GestureDetector(
                  onTap: controller.isLoading.value ? null : () => controller.signIn(),
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
                            'Sending OTP...',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ] else ...[
                          Text(
                            'Send OTP',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
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

  Widget _buildRoleToggle(SignCtrl controller) {
    return Obx(() {
      final isMukadam = controller.isMukadam;
      return Container(
        height: 44,
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            _roleTab(label: 'Coolie', icon: Icons.luggage_rounded, selected: !isMukadam, onTap: () => controller.switchRole(UserRole.coolie)),
            _roleTab(label: 'Mukadam', icon: Icons.manage_accounts_rounded, selected: isMukadam, onTap: () => controller.switchRole(UserRole.mukadam)),
          ],
        ),
      );
    });
  }

  Widget _roleTab({required String label, required IconData icon, required bool selected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          height: 44,
          decoration: BoxDecoration(
            color: selected ? Constants.instance.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected ? [BoxShadow(color: Constants.instance.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? Colors.white : const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : const Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
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
