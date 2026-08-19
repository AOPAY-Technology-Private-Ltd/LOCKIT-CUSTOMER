import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  final double width;
  final double height;

  const AuthLogo({
    super.key,
    this.width = 200,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/images/bglogo.png",
            width: width,
            height: height,
            fit: BoxFit.contain,
          ),

          Image.asset(
            "assets/images/logo.png",
            width: width * 0.6,
            height: height * 0.6,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}