import 'package:flutter/material.dart';

/// Input validators with security best practices
class Validators {
  // Email validation using RFC 5322 simplified regex
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Remove whitespace
    value = value.trim();

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    // Additional security checks
    if (value.length > 254) {
      return 'Email address is too long';
    }

    return null;
  }

  // Phone validation (supports various formats)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional in this context
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Check if it's a valid length (10-15 digits for international numbers)
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Email or Phone validation
  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email or phone is required';
    }

    value = value.trim();

    // Check if it looks like an email
    if (value.contains('@')) {
      return validateEmail(value);
    }

    // Check if it looks like a phone number
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 10) {
      return validatePhone(value);
    }

    return 'Please enter a valid email or phone number';
  }

  // Password validation with strength requirements
  static String? validatePassword(String? value,
      {bool isRegistration = false}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Minimum length check
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // For registration, enforce stronger password requirements
    if (isRegistration) {
      // Check for uppercase letter
      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'Password must contain at least one uppercase letter';
      }

      // Check for lowercase letter
      if (!value.contains(RegExp(r'[a-z]'))) {
        return 'Password must contain at least one lowercase letter';
      }

      // Check for number
      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Password must contain at least one number';
      }

      // Check for special character
      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'Password must contain at least one special character';
      }

      // Maximum length check (security best practice)
      if (value.length > 128) {
        return 'Password is too long (max 128 characters)';
      }

      // Check for common weak passwords
      final weakPasswords = [
        'password',
        '12345678',
        'password1',
        'password123',
        'qwerty123',
        'abc123456',
        '11111111',
        '00000000'
      ];

      if (weakPasswords.contains(value.toLowerCase())) {
        return 'This password is too common. Please choose a stronger one';
      }
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    value = value.trim();

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name is too long (max 50 characters)';
    }

    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // OTP validation
  static String? validateOTP(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != length) {
      return 'Please enter a $length-digit OTP';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  // Password strength calculator (0-100)
  static int calculatePasswordStrength(String password) {
    int strength = 0;

    if (password.isEmpty) return 0;

    // Length bonus
    strength += (password.length * 4).clamp(0, 40);

    // Character variety bonuses
    if (password.contains(RegExp(r'[a-z]'))) strength += 10;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 10;
    if (password.contains(RegExp(r'[0-9]'))) strength += 10;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 10;

    // Bonus for mixed case and numbers
    if (password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'))) {
      strength += 10;
    }

    // Penalty for common patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(password))
      strength -= 10; // Repeated characters
    if (RegExp(r'(012|123|234|345|456|567|678|789|890)').hasMatch(password)) {
      strength -= 10; // Sequential numbers
    }

    return strength.clamp(0, 100);
  }

  // Get password strength description
  static String getPasswordStrengthText(int strength) {
    if (strength < 30) return 'Weak';
    if (strength < 60) return 'Fair';
    if (strength < 80) return 'Good';
    return 'Strong';
  }

  // Get password strength color
  static getPasswordStrengthColor(int strength) {
    if (strength < 30) return const Color(0xFFE74C3C);
    if (strength < 60) return const Color(0xFFF39C12);
    if (strength < 80) return const Color(0xFF3498DB);
    return const Color(0xFF27AE60);
  }
}
