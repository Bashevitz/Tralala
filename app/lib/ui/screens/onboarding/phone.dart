import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tralala_app/core/providers/onboarding.provider.dart';

class OnboardingPhone extends StatefulWidget {
  const OnboardingPhone({super.key});

  @override
  State<OnboardingPhone> createState() => _OnboardingPhoneState();
}

class _OnboardingPhoneState extends State<OnboardingPhone> {
  final _phoneController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);

    // Load cached phone number if exists
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );
    if (onboardingProvider.phoneNumber != null) {
      _phoneController.text = onboardingProvider.phoneNumber!;
      _validatePhone();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    setState(() {
      _isValid = phone.length >= 10;
    });
  }

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
                'Your Phone Number',
                style: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We need your phone number to verify your account and help your friends find you.',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                style: GoogleFonts.baloo2(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  labelStyle: GoogleFonts.baloo2(color: Colors.grey[600]),
                  hintStyle: GoogleFonts.baloo2(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.phone, color: const Color(0xFF2BB8FF)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
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
                    Navigator.pushReplacementNamed(
                      context,
                      '/onboarding/permissions',
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
                          ? () {
                            // Cache phone number before navigation
                            final onboardingProvider =
                                Provider.of<OnboardingProvider>(
                                  context,
                                  listen: false,
                                );
                            onboardingProvider.setPhoneNumber(
                              _phoneController.text,
                            );

                            Navigator.pushReplacementNamed(
                              context,
                              '/onboarding/profile',
                            );
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
}
