import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:swapit_marketplace/presentation/home/main_screen.dart';


/// Email verification page shown after registration
/// Includes auto-check and manual refresh options
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isEmailVerified = false;
  bool _canResendEmail = false;
  Timer? _timer;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _isEmailVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!_isEmailVerified) {
      // Send verification email on page load
      _sendVerificationEmail();

      // Check email verification status every 3 seconds
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      _isEmailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (_isEmailVerified) {
      _timer?.cancel();

      // Navigate to main screen after verification
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      setState(() {
        _canResendEmail = false;
        _resendCountdown = 60;
      });

      // Start countdown for resend button
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCountdown > 0) {
          setState(() {
            _resendCountdown--;
          });
        } else {
          setState(() {
            _canResendEmail = true;
          });
          timer.cancel();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63E8).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 60,
                  color: Color(0xFF6C63E8),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'We\'ve sent a verification link to\n${FirebaseAuth.instance.currentUser?.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9B9B9B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Please check your email and click the verification link to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9B9B9B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Resend email button
              ElevatedButton(
                onPressed: _canResendEmail ? _sendVerificationEmail : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63E8),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _canResendEmail
                      ? 'Resend Email'
                      : 'Resend in ${_resendCountdown}s',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Check verification status button
              TextButton(
                onPressed: _checkEmailVerified,
                child: const Text(
                  'I\'ve verified my email',
                  style: TextStyle(
                    color: Color(0xFF6C63E8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF6C63E8),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Didn\'t receive the email? Check your spam folder or resend.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
