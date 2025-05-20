import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatOptionsAssets {
  // Cache SVG widgets
  static late final Widget commentIcon;
  static late final Widget profileIcon;
  static late final Widget peopleIcon;
  static late final Widget closeIcon;

  // Cache text styles
  static late final TextStyle titleStyle;
  static late final TextStyle subtitleStyle;

  // Flag to track initialization
  static bool _isInitialized = false;

  static void initAssets() {
    if (_isInitialized) return;

    commentIcon = SvgPicture.asset("assets/icons/comment.svg");
    profileIcon = SvgPicture.asset("assets/icons/profile_circle.svg");
    peopleIcon = SvgPicture.asset("assets/icons/people.svg");
    closeIcon = SvgPicture.asset("assets/icons/close.svg");

    titleStyle = GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold);
    subtitleStyle = const TextStyle(color: Colors.grey, fontSize: 12);

    _isInitialized = true;
  }
}
