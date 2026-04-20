import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:license_sahayak/screens/coolie/home/ui/coolie_reviews.dart';
import 'package:license_sahayak/screens/coolie/home/ui/feedback_sheet.dart';
import 'package:license_sahayak/services/helper.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import '../home_ctrl.dart';

class _DS {
  static const Color primary = Color(0xFFC60000);
  static const Color primaryMuted = Color(0x12C60000);
  static const Color bg = Color(0xFFF4F5F7);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFEEF0F4);
  static const Color labelPrimary = Color(0xFF0F172A);
  static const Color labelSecond = Color(0xFF475569);
  static const Color labelMuted = Color(0xFF94A3B8);
  static const double radius = 16;

  static TextStyle text(double size, FontWeight w, Color c) => GoogleFonts.dmSans(fontSize: size, fontWeight: w, color: c);
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeCtrl>(
      init: HomeCtrl(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: _DS.bg,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, controller),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final profile = controller.userProfile.value;
                        if (profile == null) return const SizedBox.shrink();
                        return _StationCard(controller: controller, stationName: profile.station["name"], stationCode: profile.station["code"]);
                      }),
                      Obx(() {
                        final profile = controller.userProfile.value;
                        if (profile == null || controller.isMukadam.value) return const SizedBox.shrink();
                        return Column(
                          children: [
                            const SizedBox(height: 24),
                            const _SectionLabel(label: 'Mukadar Information'),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: _DS.surface,
                                borderRadius: BorderRadius.circular(_DS.radius),
                                border: Border.all(color: _DS.border, width: 1),
                              ),
                              child: _buildMukadarSection(profile.mukadamId, context),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      const _SectionLabel(label: 'Personal Information'),
                      const SizedBox(height: 12),
                      Obx(() {
                        final profile = controller.userProfile.value;
                        if (profile == null) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(color: _DS.primary),
                            ),
                          );
                        }
                        return _ProfileCard(
                          items: [
                            _ProfileItem(icon: Icons.person_outline_rounded, label: 'Full Name', value: toTitleCase(profile.name)),
                            _ProfileItem(icon: Icons.alternate_email_rounded, label: 'Email Address', value: profile.emailId),
                            _ProfileItem(icon: Icons.phone_outlined, label: 'Mobile Number', value: profile.mobileNo),
                            _ProfileItem(icon: Icons.cake_outlined, label: 'Age', value: profile.age),
                            _ProfileItem(icon: Icons.badge_outlined, label: 'Buckle Number', value: profile.buckleNumber, isLast: true),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, HomeCtrl controller) {
    return SliverAppBar(
      expandedHeight: 248,
      pinned: true,
      stretch: true,
      backgroundColor: _DS.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
      title: Text('My Profile', style: _DS.text(18, FontWeight.w700, Colors.white)),
      actions: [
        Tooltip(
          message: 'My Reviews',
          child: IconButton(
            icon: const Icon(Icons.star_outline_rounded, color: Colors.white, size: 22),
            onPressed: () {
              final profile = controller.userProfile.value;
              if (profile == null) return;
              Get.to(() => CoolieReviews(user: profile));
            },
          ),
        ),
        Tooltip(
          message: 'Send Feedback',
          child: IconButton(
            icon: const Icon(Icons.rate_review_outlined, color: Colors.white, size: 22),
            onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const FeedbackSheet()),
          ),
        ),
        const SizedBox(width: 6),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: _ProfileHeader(controller: controller),
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final HomeCtrl controller;
  final String stationName;
  final String stationCode;

  const _StationCard({required this.controller, required this.stationName, required this.stationCode});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOnline = controller.isCheckedIn.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Current Station'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: _DS.surface,
              borderRadius: BorderRadius.circular(_DS.radius),
              border: Border.all(color: _DS.border, width: 1),
            ),
            child: Column(
              children: [
                _StationHeader(stationName: stationName, stationCode: stationCode, isOnline: isOnline),
                if (isOnline) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  _SessionRow(controller: controller),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _StationHeader extends StatelessWidget {
  final String stationName;
  final String stationCode;
  final bool isOnline;

  const _StationHeader({required this.stationName, required this.stationCode, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: _DS.primary, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.train_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stationName.capitalizeFirst.toString(), style: _DS.text(15, FontWeight.w600, _DS.labelPrimary)),
                const SizedBox(height: 3),
                Text('Code: $stationCode', style: _DS.text(12, FontWeight.w400, _DS.labelMuted)),
              ],
            ),
          ),
          _StatusPill(isOnline: isOnline),
        ],
      ),
    );
  }
}

Widget _buildMukadarSection(dynamic mukadar, BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 1.6),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: ClipOval(
            child: mukadar["image"] != null && mukadar["image"]!["url"] != null && mukadar["image"]!["url"] != ""
                ? GestureDetector(
                    onTap: () => helper.imageShow(uri: NetworkConstants.baseUrl + mukadar["image"]["url"], context: context),
                    child: Image.network(
                      NetworkConstants.baseUrl + mukadar["image"]["url"].toString(),
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null ? child : _AvatarFallback(size: 24),
                      errorBuilder: (_, _, _) => _AvatarFallback(size: 24),
                    ),
                  )
                : Center(
                    child: Text(
                      mukadar["name"] != null && mukadar["name"] != "" ? mukadar["name"][0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Constants.instance.primary),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Connected Mukadar",
                style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                mukadar["name"].toString().capitalizeFirst.toString(),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1A202C)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => helper.makePhoneCall(mukadar["mobileNo"]),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: const Color(0xFF16A34A).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
          ),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  final bool isOnline;

  const _StatusPill({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? const Color(0xFF16A34A) : const Color(0xFF94A3B8);
    final bg = isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9);
    final label = isOnline ? 'Online' : 'Offline';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label, style: _DS.text(11, FontWeight.w600, color)),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final HomeCtrl controller;

  const _SessionRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final punchIn = DateTime.tryParse(controller.punchInTime.value) ?? DateTime.now();
      String sessionLabel = 'Session active';
      String durationLabel = '—';
      final duration = DateTime.now().difference(punchIn);
      final h = duration.inHours;
      final m = duration.inMinutes.remainder(60);
      durationLabel = h > 0 ? '${h}h ${m}m' : '${m}m';
      final timeStr = '${punchIn.hour.toString().padLeft(2, '0')}:${punchIn.minute.toString().padLeft(2, '0')}';
      sessionLabel = 'Active since $timeStr';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            _PulsingDot(),
            const SizedBox(width: 10),
            Expanded(child: Text(sessionLabel, style: _DS.text(12.5, FontWeight.w500, _DS.labelSecond))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _DS.primaryMuted, borderRadius: BorderRadius.circular(8)),
              child: Text(durationLabel, style: _DS.text(12, FontWeight.w600, _DS.primary)),
            ),
          ],
        ),
      );
    });
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.6).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _opacity = Tween<double>(begin: 0.5, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dotColor = Color(0xFF16A34A);
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: dotColor.withOpacity(_opacity.value), shape: BoxShape.circle),
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(color: _DS.primary, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(label.toUpperCase(), style: _DS.text(10.5, FontWeight.w700, _DS.labelSecond).copyWith(letterSpacing: 1.1)),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final HomeCtrl controller;

  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFE53935), Color(0xFF9B0000)]),
          ),
        ),
        Positioned(top: -50, right: -40, child: _circle(180, 0.07)),
        Positioned(bottom: 30, left: -30, child: _circle(110, 0.05)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() {
                  final profile = controller.userProfile.value;
                  return Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white.withOpacity(0.9), width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: ClipOval(
                      child: profile != null && profile.image!.url.isNotEmpty
                          ? Image.network(
                              NetworkConstants.baseUrl + profile.image!.url,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) => progress == null ? child : _AvatarFallback(),
                              errorBuilder: (_, _, _) => _AvatarFallback(),
                            )
                          : Center(child: Text(profile != null && profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U', style: _DS.text(32, FontWeight.w800, _DS.primary))),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Obx(() {
                  final profile = controller.userProfile.value;
                  return Column(
                    children: [
                      Text(profile != null ? toTitleCase(profile.name) : '—', style: _DS.text(20, FontWeight.w700, Colors.white)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Verified Coolie', style: _DS.text(11, FontWeight.w500, Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _circle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: Colors.white.withOpacity(opacity), shape: BoxShape.circle),
  );
}

class _ProfileCard extends StatelessWidget {
  final List<_ProfileItem> items;

  const _ProfileCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DS.surface,
        borderRadius: BorderRadius.circular(_DS.radius),
        border: Border.all(color: _DS.border, width: 1),
      ),
      child: Column(children: items.map((item) => _buildTile(item)).toList()),
    );
  }

  Widget _buildTile(_ProfileItem item) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: _DS.primaryMuted, borderRadius: BorderRadius.circular(10)),
                child: Icon(item.icon, color: _DS.primary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label, style: _DS.text(10.5, FontWeight.w500, _DS.labelMuted)),
                    const SizedBox(height: 2),
                    Text(item.value.isEmpty ? '—' : item.value, style: _DS.text(14, FontWeight.w600, _DS.labelPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!item.isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
      ],
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _ProfileItem({required this.icon, required this.label, required this.value, this.isLast = false});
}

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.toLowerCase().split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w).join(' ');
}

class _AvatarFallback extends StatelessWidget {
  final double? size;

  const _AvatarFallback({this.size});

  @override
  Widget build(BuildContext context) => Container(
    color: _DS.primary,
    child: Icon(Icons.person_rounded, color: Colors.white, size: size ?? 42),
  );
}
