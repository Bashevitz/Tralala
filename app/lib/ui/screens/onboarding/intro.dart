import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingStart extends StatelessWidget {
  const OnboardingStart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40),
                SizedBox(
                  width: 400,
                  height: 300,
                  child: Image.asset('assets/images/humaaans.png'),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    Text(
                      'Send your goofy ahh memes with no risk of leaking the GC.',
                      style: GoogleFonts.baloo2(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to Terms & Privacy Policy
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2BB8FF),
                      ),
                      child: Text(
                        'Terms & Privacy Policy',
                        style: GoogleFonts.baloo2(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/onboarding/permissions',
                          );
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
                          'Continue',
                          style: GoogleFonts.baloo2(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
