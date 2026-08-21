import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/network/network_service.dart';

import '../../../../auth/presentation/common/widgets/auth_button.dart';
import '../../../../auth/presentation/common/widgets/auth_footer.dart';
import '../../../../auth/presentation/common/widgets/auth_logo.dart';
import '../../../../auth/presentation/common/widgets/curved_top_container.dart';
import '../../../../auth/presentation/common/widgets/no_internet_widget.dart';
import '../../bloc/generate_key_bloc.dart';

class SecurityKeyView extends StatefulWidget {
  const SecurityKeyView({super.key});

  @override
  State<SecurityKeyView> createState() => _SecurityKeyViewState();
}

class _SecurityKeyViewState extends State<SecurityKeyView> with WidgetsBindingObserver {
  String? errorMessage;
  String displayedKey = "---- ---- ---- ----";
  int remainingSeconds = 105;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) {
        return const PopScope(
          canPop: false,
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2563EB),
            ),
          ),
        );
      },
    );
  }

  void _hideLoader(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _onGenerateKeyClicked() async {
    final bool hasConnection = await NetworkService.hasInternet();
    if (!hasConnection) {
      setState(() {
        errorMessage = 'No internet connection';
      });
      return;
    }

    setState(() {
      errorMessage = null;
    });

    if (!mounted) return;
    context.read<GenerateKeyBloc>().add(RequestGenerateKeyEvent());
  }

  String _formatTimer(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: BlocListener<GenerateKeyBloc, GenerateKeyState>(
        listener: (context, state) {
          if (state is GenerateKeyLoading) {
            _showLoader(context);
          } else {
            _hideLoader(context);
          }

          if (state is GenerateKeyError) {
            if (!mounted) return;
            setState(() {
              errorMessage = state.message;
            });
          }
          else if (state is GenerateKeySuccess) {
            if (!mounted) return;
            setState(() {
              displayedKey = state.keyCode;
              errorMessage = null;
            });
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
              final bool isKeyboardVisible = keyboardHeight > 0;
              final double imageSize = isKeyboardVisible ? 90.0 : 150.0;

              return Container(
                width: double.infinity,
                height: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: AppTheme.loginGradient,
                ),
                child: Stack(
                  children: [
                    if (!isKeyboardVisible)
                      Positioned(
                        top: height * 0.05,
                        left: 0,
                        right: 0,
                        child: const AuthLogo(),
                      ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      left: -width * 0.36,
                      bottom: isKeyboardVisible ? keyboardHeight - 20 : 0,
                      child: SizedBox(
                        width: width * 1.76,
                        height: height * 0.65,
                        child: CurvedTopContainer(
                          curveHeight: 0.28,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: height * 0.03,
                              left: width * 0.40,
                              right: width * 0.40,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F5FF),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE9D5FF)),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFE0E7FF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.key_rounded,
                                            color: Color(0xFF7C3AED),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          "YOUR SECURITY KEY",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF7C3AED),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Text(
                                            displayedKey,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1F2937),
                                              letterSpacing: 1.2,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: height * 0.015),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.access_alarm_rounded,
                                        size: 45,
                                        color: Colors.orange,
                                      ),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: CircularProgressIndicator(
                                              value: 0.75,
                                              strokeWidth: 5,
                                              backgroundColor: Colors.grey,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _formatTimer(remainingSeconds),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              const Text(
                                                "MINUTES",
                                                style: TextStyle(fontSize: 6, color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: height * 0.015),

                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFC7D2FE)),
                                    ),
                                    child: Column(
                                      children: const [
                                        Text(
                                          "Key Expiration Alert",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4F46E5),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          "Your access key will expire in 2 minutes. Generate a new key before it expires.",
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: height * 0.015),

                                  if (errorMessage != null &&
                                      errorMessage!.contains('No internet connection'))
                                    SizedBox(
                                      height: 70,
                                      child: NoInternetWidget(
                                        onRetry: () {
                                          setState(() {
                                            errorMessage = null;
                                          });
                                          _onGenerateKeyClicked();
                                        },
                                      ),
                                    )
                                  else ...[
                                    if (errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          errorMessage!,
                                          style: const TextStyle(color: Colors.red, fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    AuthButton(
                                      title: "Generate Key",
                                      onTap: _onGenerateKeyClicked,
                                    ),
                                    SizedBox(height: height * 0.008),
                                    const AuthFooter(),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}