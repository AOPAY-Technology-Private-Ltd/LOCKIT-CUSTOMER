import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MobileInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const MobileInput({
    super.key,
    required this.controller,
    required this.focusNode,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final text = value.text;

        final bool isNumericMode =
            text.isNotEmpty &&
                RegExp(r'^[0-9]+$').hasMatch(text);

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
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,

                keyboardType: TextInputType.emailAddress,

                textInputAction: TextInputAction.done,

                autocorrect: false,
                enableSuggestions: false,

                onSubmitted: (_) {
                  focusNode.unfocus();

                  if (onSubmitted != null) {
                    onSubmitted!();
                  }
                },

                onChanged: onChanged,

                inputFormatters: isNumericMode
                    ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
                    : [],

                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),

                decoration: InputDecoration(
                  prefix: isNumericMode
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

                  fillColor:
                  Colors.white.withOpacity(0.5),

                  hintText:
                  "Enter mobile number or Email",

                  hintStyle:
                  theme.textTheme.labelMedium,

                  contentPadding:
                  EdgeInsets.symmetric(
                    horizontal:
                    screenWidth * 0.05,
                    vertical: 17,
                  ),

                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: errorText != null
                          ? theme.colorScheme.error
                          : Colors.black
                          .withOpacity(0.6),
                      width: 1,
                    ),
                  ),

                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: errorText != null
                          ? theme.colorScheme.error
                          : Colors.black
                          .withOpacity(0.6),
                      width: 1,
                    ),
                  ),

                  errorBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color:
                      theme.colorScheme.error,
                      width: 1,
                    ),
                  ),

                  focusedErrorBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color:
                      theme.colorScheme.error,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            if (errorText != null) ...[
              const SizedBox(height: 6),

              Padding(
                padding:
                const EdgeInsets.only(left: 4),

                child: Text(
                  errorText!,

                  style: TextStyle(
                    color:
                    theme.colorScheme.error,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}