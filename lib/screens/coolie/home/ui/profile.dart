import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:license_sahayak/services/helper.dart';
import '../../../../utils/app_constants.dart';
import '../home_ctrl.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeCtrl>(
      init: HomeCtrl(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, controller),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Personal Information'),
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
                      _buildSectionLabel('Account Actions'),
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

  Widget _buildSliverAppBar(BuildContext context, HomeCtrl controller) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: Constants.instance.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(background: _ProfileHeader(controller: controller)),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 1.2),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final HomeCtrl controller;

  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Constants.instance.primary, Constants.instance.primary.withOpacity(0.75)]),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 36),
            Obx(() {
              final profile = controller.userProfile.value;
              return Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: ClipOval(
                  child: profile != null && profile.image!.url.isNotEmpty
                      ? Image.network(
                          NetworkConstants.baseUrl + profile.image!.url,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) => progress == null ? child : _AvatarFallback(),
                          errorBuilder: (_, _, _) => _AvatarFallback(),
                        )
                      : Center(
                          child: Text(
                            profile != null && profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                            style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Constants.instance.primary),
                          ),
                        ),
                ),
              );
            }),
            const SizedBox(height: 14),
            Obx(() {
              final profile = controller.userProfile.value;
              return Column(
                children: [
                  Text(
                    profile != null ? toTitleCase(profile.name) : '—',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 4),
                  Text(profile?.emailId ?? '', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                ],
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final List<_ProfileItem> items;

  const _ProfileCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(children: items.map((item) => _buildTile(context, item)).toList()),
    );
  }

  Widget _buildTile(BuildContext context, _ProfileItem item) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Constants.instance.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, color: Constants.instance.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500, letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.value.isEmpty ? "---" : item.value,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!item.isLast) Divider(height: 1, thickness: 1, indent: 76, endIndent: 20, color: Colors.grey.shade100),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 2),
                      Text('Permanently remove your account', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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
  return text.toLowerCase().split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word).join(' ');
}

Future<void> deleteAccount(BuildContext context) async {
  const url = 'https://docs.google.com/forms/d/e/1FAIpQLSe_6UsyVHh5hX02k2N-uaAz26Kl9iTim2fTskkyppcthKmlDQ/viewform?pli=1';
  bool? confirmDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action is permanent and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  if (confirmDelete == true) {
    await helper.launchURL(url);
  }
}

class _AvatarFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFC60000),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 42),
    );
  }
}
