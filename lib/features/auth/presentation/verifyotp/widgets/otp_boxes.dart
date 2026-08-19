import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'otp_input_field.dart';

class OtpBoxes extends StatefulWidget {
  final TextEditingController controller;

  const OtpBoxes({
    super.key,
    required this.controller,
  });

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  static const int length = 4;

  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();

    controllers = List.generate(
      length,
          (_) => TextEditingController(),
    );

    focusNodes = List.generate(
      length,
          (_) => FocusNode(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes.first.requestFocus();
    });
  }

  void _updateOtp() {
    widget.controller.text = controllers.map((e) => e.text).join();
  }

  void _onChanged(int index, String value) {
    _updateOtp();

    if (value.isNotEmpty) {
      if (index < length - 1) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
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
              child: CallbackShortcuts(
                bindings: <ShortcutActivator, VoidCallback>{
                  const SingleActivator(LogicalKeyboardKey.backspace): () {
                    if (controllers[index].text.isEmpty && index > 0) {
                      focusNodes[index - 1].requestFocus();
                      controllers[index - 1].clear();
                      _updateOtp();
                    } else if (controllers[index].text.isNotEmpty) {
                      controllers[index].clear();
                      _updateOtp();
                    }
                  },
                },
                child: OtpInputField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  onChanged: (value) {
                    _onChanged(index, value);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }
}