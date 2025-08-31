import 'package:flutter/material.dart';

/// Design tokens for the ShoulderAbductionPage
/// Contains all radius, colors, shadows, and typography constants
class DesignTokens {
  // Radius values
  static const double cardRadius = 24.0;
  static const double buttonPillRadius = 28.0;
  static const double fieldRadius = 16.0;

  // Colors
  static const Color textPrimary = Color(0xFF121212);
  static const Color textSecondary = Color(0xFF424242);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFFAFAFA);
  static const Color primaryDark = Color(0xFF3A3A3A);
  static const Color border = Color(0xFFE9E9E9);

  // Shadow configuration
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1F000000), // rgba(0,0,0,0.12)
    blurRadius: 12.0,
    spreadRadius: 0.0,
    offset: Offset(0, 2),
  );

  // Typography styles
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle valueStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Responsive breakpoints
  static const double phoneBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  // Responsive padding
  static double getHorizontalPadding(double screenWidth) {
    if (screenWidth >= tabletBreakpoint) return 40.0;
    if (screenWidth >= phoneBreakpoint) return 32.0;
    return 24.0;
  }

  static double getVerticalSpacing(double screenWidth) {
    if (screenWidth >= phoneBreakpoint) return 28.0;
    return 24.0;
  }

  // Responsive font sizes
  static double getTitleFontSize(double screenWidth) {
    return screenWidth >= phoneBreakpoint ? 32.0 : 28.0;
  }

  static double getValueFontSize(double screenWidth) {
    return screenWidth >= phoneBreakpoint ? 48.0 : 42.0;
  }

  static double getInputFontSize(double screenWidth) {
    return 22.0; // Same for all screen sizes
  }

  // Responsive button heights
  static double getPillButtonHeight(double screenWidth) {
    return screenWidth >= phoneBreakpoint ? 48.0 : 44.0;
  }

  static double getPrimaryButtonHeight(double screenWidth) {
    return screenWidth >= phoneBreakpoint ? 64.0 : 56.0;
  }

  // Responsive card padding
  static double getCardPadding(double screenWidth) {
    return screenWidth >= phoneBreakpoint ? 24.0 : 20.0;
  }

  static double getFieldPadding(double screenWidth) {
    return screenWidth >= phoneBreakpoint ? 20.0 : 16.0;
  }
}
