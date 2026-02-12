import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationCodeDisplay extends StatelessWidget {
  const VerificationCodeDisplay({
    super.key,
    required this.verificationCode,
  });

  final String verificationCode;

  @override
  Widget build(BuildContext context) => Text(
        verificationCode,
        style: GoogleFonts.inconsolata(
          color: Colors.grey.shade500,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
}
