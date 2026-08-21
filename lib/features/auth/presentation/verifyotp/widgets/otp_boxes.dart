import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpBoxes extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  const OtpBoxes({
    super.key,
    required this.controller,
    this.onCompleted,
  });

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  static const int length = 4;

  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  static const String _emptyChar = '\u200b';

  @override
  void initState() {
    super.initState();

    controllers = List.generate(
      length,
          (_) => TextEditingController(text: _emptyChar),
    );

    focusNodes = List.generate(
      length,
          (_) => FocusNode(),
    );

    for (int i = 0; i < length; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          if (controllers[i].text.isEmpty || controllers[i].text == _emptyChar) {
            controllers[i].text = _emptyChar;
            controllers[i].selection = TextSelection.fromPosition(
              TextPosition(offset: controllers[i].text.length),
            );
          }
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes.first.requestFocus();
    });
  }

  void _updateOtp() {
    final otp = controllers
        .map((e) => e.text.replaceAll(_emptyChar, ''))
        .join();
    widget.controller.text = otp;
    if (otp.length == length && widget.onCompleted != null) {
      widget.onCompleted!(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final boxWidth = ((width - 100) / length).clamp(42.0, 52.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
            (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: SizedBox(
              width: boxWidth,
              height: 48,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                keyboardType: TextInputType.number,
                textInputAction: index == length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                maxLength: 2,
                cursorColor: Colors.black,
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                onChanged: (value) {
                  final cleanValue = value.replaceAll(_emptyChar, '');

                  if (cleanValue.isNotEmpty) {
                    final lastChar = cleanValue[cleanValue.length - 1];
                    controllers[index].text = _emptyChar + lastChar;
                    controllers[index].selection = TextSelection.fromPosition(
                      TextPosition(offset: controllers[index].text.length),
                    );

                    _updateOtp();

                    if (index < length - 1) {
                      focusNodes[index + 1].requestFocus();
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  } else {
                    controllers[index].text = _emptyChar;
                    controllers[index].selection = TextSelection.fromPosition(
                      TextPosition(offset: controllers[index].text.length),
                    );
                    _updateOtp();

                    if (index > 0) {
                      focusNodes[index - 1].requestFocus();
                      controllers[index - 1].text = _emptyChar;
                      controllers[index - 1].selection = TextSelection.fromPosition(
                        TextPosition(offset: controllers[index - 1].text.length),
                      );
                      _updateOtp();
                    }
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}