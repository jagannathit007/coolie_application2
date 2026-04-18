import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:license_sahayak/screens/coolie/home/ui/coolie_reviews.dart';
import 'package:license_sahayak/screens/coolie/home/ui/feedback_sheet.dart';
import 'package:license_sahayak/services/helper.dart';
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
                      _SectionLabel(label: 'Personal Information'),
                      const SizedBox(height: 12),
                      Obx(() {
                        final profile = controller.userProfile.value;
                        if (profile == null) {
                          return const Center(
                            child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()),
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
                      const SizedBox(height: 28),
                      _SectionLabel(label: 'Account'),
                      const SizedBox(height: 12),
                      _DeleteAccountTile(controller: controller),
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

class _DeleteAccountTile extends StatelessWidget {
  final HomeCtrl controller;

  const _DeleteAccountTile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DS.surface,
        borderRadius: BorderRadius.circular(_DS.radius),
        border: Border.all(color: _DS.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_DS.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_DS.radius),
          onTap: () => deleteAccount(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Account',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.error),
                      ),
                      Text(
                        'Permanently remove your account',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: const Color(0xFFF87171)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.toLowerCase().split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w).join(' ');
}

Future<void> deleteAccount(BuildContext context) async {
  const url = 'https://docs.google.com/forms/d/e/1FAIpQLSe_6UsyVHh5hX02k2N-uaAz26Kl9iTim2fTskkyppcthKmlDQ/viewform?pli=1';
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Delete Account', style: _DS.text(17, FontWeight.w700, _DS.labelPrimary)),
      content: Text('Are you sure you want to delete your account? This action is permanent and cannot be undone.', style: _DS.text(13, FontWeight.w400, _DS.labelSecond)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancel', style: _DS.text(14, FontWeight.w600, _DS.labelSecond)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text('Delete', style: _DS.text(14, FontWeight.w600, Colors.white)),
        ),
      ],
    ),
  );
  if (confirm == true) await helper.launchURL(url);
}

class _AvatarFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: _DS.primary,
    child: const Icon(Icons.person_rounded, color: Colors.white, size: 42),
  );
}
