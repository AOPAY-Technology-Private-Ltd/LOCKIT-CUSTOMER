import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final TextInputAction textInputAction;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      onSubmitted: (_) {
        FocusScope.of(context).unfocus();
      },
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      maxLength: 1,
      cursorColor: Colors.black,
      autofillHints: const [
        AutofillHints.oneTimeCode,
      ],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF2563EB),
            width: 1.5,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }
}