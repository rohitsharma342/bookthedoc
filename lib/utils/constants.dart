import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF2E7D8F);
  static const Color secondaryColor = Color(0xFF4A9EAF);
  static const Color accentColor = Color(0xFF7BC3D1);
  static const Color backgroundColor = Color(0xFFF8FAFB);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color dividerColor = Color(0xFFECF0F1);

  // Specialties
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

  // Consultation Types
  static const List<String> consultationTypes = [
    'In-person',
    'Video Call',
    'Phone Call',
  ];

  // App Settings
  static const String appName = 'BookTheDoc';
  static const String appVersion = '1.0.0';
  
  // API Endpoints (if needed for external services)
  static const String baseUrl = 'https://api.bookthedoc.com';
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(seconds: 3);
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
}