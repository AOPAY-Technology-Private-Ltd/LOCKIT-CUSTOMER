import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MobileInput extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const MobileInput({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  State<MobileInput> createState() => _MobileInputState();
}

class _MobileInputState extends State<MobileInput> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final text = widget.controller.text;

    final bool isEmailOrTextMode = text.contains('@') || RegExp(r'[a-zA-Z.]').hasMatch(text);
    final bool isNumericMode = !isEmailOrTextMode && RegExp(r'^[0-9]*$').hasMatch(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: TextField(
            controller: widget.controller,
            keyboardType: isEmailOrTextMode ? TextInputType.emailAddress : TextInputType.text,

            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              FocusScope.of(context).unfocus();
            },

            onChanged: (val) {
              setState(() {});
              if (widget.onChanged != null) {
                widget.onChanged!(val);
              }
            },
            inputFormatters: isEmailOrTextMode
                ? []
                : [LengthLimitingTextInputFormatter(10)],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefix: (isNumericMode && text.isNotEmpty)
                  ? const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Text(
                  "+91 ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              hintText: "Enter mobile number or Email",
              hintStyle: theme.textTheme.labelMedium,
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 17,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: widget.errorText != null
                      ? theme.colorScheme.error
                      : Colors.black.withOpacity(0.6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: widget.errorText != null
                      ? theme.colorScheme.error
                      : Colors.black.withOpacity(0.6),
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}