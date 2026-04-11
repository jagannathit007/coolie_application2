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
          appBar: AppBar(
            backgroundColor: Constants.instance.primary,
            leading: BackButton(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                Center(
                  child: Obx(() {
                    final profile = controller.userProfile.value;
                    return CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: profile != null && profile.image!.url.isNotEmpty ? NetworkImage("${NetworkConstants.imageURL}${profile.image!.url}") : null,
                      child: profile == null || profile.image!.url.isEmpty ? Icon(Icons.person, size: 40, color: Constants.instance.grey100) : null,
                    );
                  }),
                ),
                SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Constants.instance.grey100,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Obx(() {
                        final profile = controller.userProfile.value;
                        if (profile == null) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailTile(Icons.person, "Name", toTitleCase(profile.name)),
                            _divider(),
                            _buildDetailTile(Icons.alternate_email, "Email", profile.emailId),
                            _divider(),
                            _buildDetailTile(Icons.call, "Mobile No.", profile.mobileNo),
                            _divider(),
                            _buildDetailTile(Icons.date_range, "Age", profile.age),
                            _divider(),
                            _buildDetailTile(Icons.star, "Buckle No.", profile.buckleNumber),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                _buildLogoutButton(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildDetailTile(IconData icon, String title, String value) {
  return Row(
    children: [
      CircleAvatar(
        radius: 20,
        backgroundColor: Constants.instance.primary.withOpacity(0.1),
        child: Icon(icon, color: Constants.instance.primary),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ],
  );
}

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.toLowerCase().split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word).join(' ');
}

Widget _divider() => Divider(color: Colors.grey.shade300, height: 24);

Widget _buildLogoutButton(BuildContext context, HomeCtrl controller) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        deleteAccount(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).colorScheme.error.withOpacity(0.1)),
        child: Row(
          children: [
            Icon(Icons.delete, color: Theme.of(context).colorScheme.error, size: 24),
            const SizedBox(width: 16),
            Text(
              'Delete Account',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    ),
  );
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
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
  if (confirmDelete == true) {
    await helper.launchURL(url);
  }
}
