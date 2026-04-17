import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:license_sahayak/routes/route_name.dart';
import 'package:license_sahayak/screens/coolie/home/home_ctrl.dart';
import 'package:license_sahayak/utils/app_config.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeaderUI extends StatelessWidget {
  final HomeCtrl controller;

  const HomeHeaderUI({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = controller.userProfile.value?.name ?? 'Coolie';
      final imageUrl = controller.userProfile.value?.image?.url ?? "";
      final buckleNumber = controller.userProfile.value?.buckleNumber ?? "---";
      final checkedIn = controller.isCheckedIn.value;
      final status = controller.checkStatuss.value.toLowerCase();
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Constants.instance.primary, Color.lerp(Constants.instance.primary, Colors.black, 0.20)!]),
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
          boxShadow: [BoxShadow(color: Constants.instance.primary.withOpacity(0.30), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await Get.toNamed(RouteName.profile);
                        await controller.fetchUserProfile();
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: ClipOval(child: _ProfileImage(imageUrl: imageUrl)),
                          ),
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: checkedIn ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            checkedIn ? 'On Duty 👋' : 'Good day,',
                            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            name,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconButton(icon: Icons.logout_rounded, onTap: _showLogoutDialog),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  spacing: 10.0,
                  children: [
                    _StatusChip(isCheckedIn: checkedIn, status: status),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.20)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.confirmation_number, size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            buckleNumber.toUpperCase(),
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _StatsRow(controller: controller),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), shape: BoxShape.circle),
                child: Icon(Icons.logout_rounded, color: Constants.instance.primary, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                'Log Out?',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 6),
              Text(
                'Are you sure you want to log out from ${AppConfig.appName}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8), height: 1.5),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  Get.close(1);
                  await controller.logOut();
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Constants.instance.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Constants.instance.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 5))],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Log Out',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Get.close(1),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isCheckedIn;
  final String status;

  const _StatusChip({required this.isCheckedIn, required this.status});

  Color get _dotColor {
    if (!isCheckedIn) return const Color(0xFF94A3B8);
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'accepted':
        return const Color(0xFF22C55E);
      case 'in-progress':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF22C55E);
    }
  }

  String get _label {
    if (!isCheckedIn) return 'Off Duty';
    switch (status) {
      case 'pending':
        return 'Request Incoming';
      case 'accepted':
        return 'Job Accepted';
      case 'in-progress':
        return 'In Progress';
      default:
        return 'On Duty — Ready';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            _label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final HomeCtrl controller;

  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCheckedIn = controller.isCheckedIn.value;
      final isApprovalRequested = controller.userProfile.value?.isApprovalRequested ?? false;
      final isCheckInLoading = controller.isCheckInLoading.value;
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: isCheckInLoading || isApprovalRequested
                  ? null
                  : () async {
                      if (isCheckedIn) {
                        await controller.checkOut();
                      } else {
                        await controller.performCheckIn();
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 48,
                decoration: BoxDecoration(
                  color: isApprovalRequested
                      ? Colors.grey.shade100
                      : isCheckedIn
                      ? Colors.white.withOpacity(0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(isCheckedIn ? 0.25 : 1.0), width: 1.5),
                ),
                child: isCheckInLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Constants.instance.primary)),
                          const SizedBox(width: 8),
                          Obx(
                            () => Text(
                              controller.checkInStatusMessage.value.isNotEmpty ? controller.checkInStatusMessage.value : 'Please wait...',
                              style: GoogleFonts.poppins(fontSize: 12, color: Constants.instance.primary, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCheckedIn ? Icons.logout_rounded : Icons.fingerprint_rounded,
                            size: 18,
                            color: isApprovalRequested
                                ? Colors.grey
                                : isCheckedIn
                                ? Colors.white
                                : Constants.instance.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isApprovalRequested
                                ? "Wating for Approval..."
                                : isCheckedIn
                                ? 'Check Out'
                                : 'Check In',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isApprovalRequested
                                  ? Colors.grey
                                  : isCheckedIn
                                  ? Colors.white
                                  : Constants.instance.primary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TOTAL JOBS',
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 9, letterSpacing: 0.6, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    controller.completedToday.value.toString(),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ProfileImage extends StatelessWidget {
  final String imageUrl;

  const _ProfileImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = NetworkConstants.baseUrl + imageUrl;
    if (url.isEmpty || imageUrl.isEmpty) {
      return _Fallback();
    }
    return Image.network(url, fit: BoxFit.cover, width: 52, height: 52, loadingBuilder: (_, child, progress) => progress == null ? child : _Fallback(), errorBuilder: (_, _, _) => _Fallback());
  }
}

class _Fallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFC60000),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
    );
  }
}
