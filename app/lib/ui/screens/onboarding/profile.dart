import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tralala_app/core/providers/onboarding.provider.dart';
import 'package:tralala_app/core/providers/user.provider.dart';
import 'package:tralala_app/ui/screens/root.dart';

class OnboardingProfile extends StatefulWidget {
  const OnboardingProfile({super.key});

  @override
  State<OnboardingProfile> createState() => _OnboardingProfileState();
}

class _OnboardingProfileState extends State<OnboardingProfile> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Load cached profile data if exists
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );
    if (onboardingProvider.firstName != null) {
      _firstNameController.text = onboardingProvider.firstName!;
    }
    if (onboardingProvider.lastName != null) {
      _lastNameController.text = onboardingProvider.lastName!;
    }

    // Add listeners to validate input
    _firstNameController.addListener(_validateInput);
    _lastNameController.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isValid =
          _firstNameController.text.trim().length > 2 &&
          _lastNameController.text.trim().length > 2;
    });
  }

  //we create an helper method to display a snackbar for feedback
  _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set Up Your Profile',
                style: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tell us a bit about yourself so your friends can find you.',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _firstNameController,
                style: GoogleFonts.baloo2(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter your first name',
                  labelStyle: GoogleFonts.baloo2(color: Colors.grey[600]),
                  hintStyle: GoogleFonts.baloo2(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                style: GoogleFonts.baloo2(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Enter your last name',
                  labelStyle: GoogleFonts.baloo2(color: Colors.grey[600]),
                  hintStyle: GoogleFonts.baloo2(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 32),
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
                    Navigator.pushReplacementNamed(
                      context,
                      '/onboarding/phone',
                    );
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
                    'Back',
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
                  onPressed:
                      _isValid
                          ? () async {
                            final firstName = _firstNameController.text.trim();
                            final lastName = _lastNameController.text.trim();

                            if (firstName.isEmpty || lastName.isEmpty) {
                              _showSnackbar("All fields are required");
                              return;
                            }

                            setState(() => _isLoading = true);
                            try {
                              // Cache profile data before navigation
                              final onboardingProvider =
                                  Provider.of<OnboardingProvider>(
                                    context,
                                    listen: false,
                                  );

                              final storage = FlutterSecureStorage();
                              final deviceId = await storage.read(
                                key: "DeviceID",
                              );

                              // login user and get response message
                              final result = await context
                                  .read<UserProvider>()
                                  .register(
                                    firstName,
                                    lastName,
                                    onboardingProvider.phoneNumber!,
                                    deviceId!,
                                  );
                              if (result == "success") {
                                // Navigate to root and remove all previous routes
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const Root(),
                                  ),
                                );
                              } else {
                                setState(() => _isLoading = false);
                                _showSnackbar(
                                  result ?? "An error occurred, try again",
                                );
                              }
                            } catch (e) {
                              setState(() => _isLoading = false);
                              _showSnackbar(
                                "Check your internet connection and try again",
                              );
                              debugPrint("$e");
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BB8FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[600],
                  ),
                  child:
                      _isLoading
                          ? LoadingAnimationWidget.waveDots(
                            color: Colors.white,
                            size: 24,
                          )
                          : Text(
                            'Complete',
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
}
