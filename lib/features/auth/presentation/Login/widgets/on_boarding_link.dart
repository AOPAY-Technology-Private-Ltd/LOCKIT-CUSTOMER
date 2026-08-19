import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class OnboardingLink extends StatelessWidget {
  final VoidCallback onTap;

  const OnboardingLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
            ),
            children: [
              const TextSpan(
                text: 'New Retailer? ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Start Onboarding →',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()..onTap = onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}