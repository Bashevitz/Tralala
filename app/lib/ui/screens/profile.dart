import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tralala_app/core/providers/user.provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.shade400,
                            Colors.lightBlue.shade200,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (user?.first.substring(0, 1).toUpperCase() ?? '') +
                              (user?.last.substring(0, 1).toUpperCase() ?? ''),
                          style: GoogleFonts.baloo2(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?.first} ${user?.last}',
                        style: GoogleFonts.baloo2(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.phone ?? '',
                        style: GoogleFonts.baloo2(
                          fontSize: 16,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Settings Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.baloo2(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      // Handle notifications settings
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy',
                    onTap: () {
                      // Handle privacy settings
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.security_outlined,
                    title: 'Security',
                    onTap: () {
                      // Handle security settings
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      // Handle help & support
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.red : Colors.blue[400]),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.baloo2(
                fontSize: 16,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: isDestructive ? Colors.red : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
