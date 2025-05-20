import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPermissions extends StatelessWidget {
  const OnboardingPermissions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Permissions',
                style: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We need some permissions to make your experience better:',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              _buildPermissionItem(
                icon: Icons.notifications,
                title: 'Notifications',
                description: 'Get notified when someone messages you',
              ),
              _buildPermissionItem(
                icon: Icons.photo_camera,
                title: 'Camera',
                description: 'Take photos and videos to share with friends',
              ),
              _buildPermissionItem(
                icon: Icons.photo_library,
                title: 'Photo Library',
                description: 'Share photos and videos from your gallery',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/onboarding/phone');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2BB8FF),
                    side: const BorderSide(color: Color(0xFF2BB8FF)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Not Now',
                    style: GoogleFonts.baloo2(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Request permissions
                    Navigator.pushNamed(context, '/onboarding/phone');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BB8FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.baloo2(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF2BB8FF)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.baloo2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.baloo2(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
