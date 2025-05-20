import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key, required this.gradient, this.style});

  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback:
          (bounds) => gradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
      child: Text("Tralala", style: GoogleFonts.luckiestGuy(textStyle: style)),
    );
  }
}
