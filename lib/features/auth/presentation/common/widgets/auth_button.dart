import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const AuthButton({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 54,
      width: double.infinity,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF008EFD),
            Color(0xFF022062),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}