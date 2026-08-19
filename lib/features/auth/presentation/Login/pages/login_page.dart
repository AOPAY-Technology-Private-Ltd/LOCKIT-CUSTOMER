import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/validators.dart';
import '../../../../../core/constants/routes/route_names.dart';
import '../../common/widgets/auth_footer.dart';
import '../../common/widgets/no_internet_widget.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

import '../../common/widgets/auth_logo.dart';
import '../../common/widgets/auth_image_slider.dart';
import '../../common/widgets/auth_button.dart';
import '../../common/widgets/curved_top_container.dart';

import '../widgets/mobile_input.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController mobileController = TextEditingController();
  String? errorMessage;

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  void _showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }

  void _hideLoader(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginLoading) {
              _showLoader(context);
            } else {
              _hideLoader(context);
            }

            if (state is LoginFailure) {
              setState(() {
                errorMessage = state.error;
              });
            } else if (state is LoginSuccess) {
              context.push(
                RouteNames.otpVerification,
                extra: state.mobile,
              );
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              final bool isKeyboardVisible = keyboardHeight > 0;
              final double imageSize = isKeyboardVisible ? 110.0 : 300.0;

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
                        top: height * 0.06,
                        left: 0,
                        right: 0,
                        child: const AuthLogo(),
                      ),

                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      top: isKeyboardVisible ? height * 0.02 : height * 0.20,
                      left: (width - imageSize) / 2,
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: AuthImageSlider(
                          size: imageSize,
                        ),
                      ),
                    ),

                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      left: -width * 0.36,
                      bottom: isKeyboardVisible ? keyboardHeight - 20 : 0,
                      child: SizedBox(
                        width: width * 1.76,
                        height: height * 0.46,
                        child: CurvedTopContainer(
                          curveHeight: 0.42,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: height * 0.08,
                              left: width * 0.41,
                              right: width * 0.41,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Welcome Back",
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.02,
                                ),

                                if (errorMessage != null &&
                                    errorMessage!.contains('No internet connection')) ...[
                                  Expanded(
                                    child: NoInternetWidget(
                                      onRetry: () {
                                        setState(() {
                                          errorMessage = null;
                                        });
                                        String input = mobileController.text.trim();
                                        if (input.startsWith("+91 ")) {
                                          input = input.substring(4).trim();
                                        }
                                        context.read<LoginBloc>().add(
                                          SendOtpPressed(mobile: input),
                                        );
                                      },
                                    ),
                                  ),
                                ] else ...[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 6,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          text: "Mobile Number or Email",
                                          style: theme.textTheme.labelSmall,
                                          children: [
                                            TextSpan(
                                              text: "*",
                                              style: TextStyle(
                                                color: colorScheme.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  MobileInput(
                                    controller: mobileController,
                                    errorText: errorMessage,
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),

                                  AuthButton(
                                    title: "Send OTP →",
                                    onTap: () {
                                      String input = mobileController.text.trim();

                                      if (input.startsWith("+91 ")) {
                                        input = input.substring(4).trim();
                                      }

                                      final error = Validators.validateInput(input);

                                      if (error != null) {
                                        setState(() {
                                          errorMessage = error;
                                        });
                                      } else {
                                        setState(() {
                                          errorMessage = null;
                                        });

                                        context.goNamed(
                                          RouteNames.otpVerification,
                                          extra: input,
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    height: height * 0.015,
                                  ),

                                  const SizedBox(height: 10),
                                  const AuthFooter(),
                                ],
                              ],
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