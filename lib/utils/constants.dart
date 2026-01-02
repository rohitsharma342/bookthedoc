import 'package:flutter/material.dart';

class AppConstants {
  static const Color primaryColor = Color(0xFF00BDA0);
  static const Color secondaryColor = Color(0xFF00A08B);
  static const Color accentColor = Color(0xFF80E6D9);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFF39C12);

  static const String appName = 'BookTheDoc';
  static const String tagline = 'Made With BrainBox';
  
  static const List<String> specialties = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Pediatrics',
    'Orthopedics',
    'Psychiatry',
    'General Medicine',
    'Gynecology',
    'Dentistry',
    'Ophthalmology',
  ];

  static const List<String> consultationTypes = [
    'In-person',
    'Video Call',
    'Audio Call',
    'Chat'
  ];

  static const Duration splashDuration = Duration(seconds: 3);
}