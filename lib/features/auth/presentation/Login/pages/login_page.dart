import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/validators.dart';
import '../../../../../../core/network/network_service.dart';
import '../../../../../core/constants/routes/route_names.dart';

import '../../common/widgets/auth_footer.dart';
import '../../common/widgets/no_internet_widget.dart';
import '../../common/widgets/auth_logo.dart';
import '../../common/widgets/auth_image_slider.dart';
import '../../common/widgets/auth_button.dart';
import '../../common/widgets/curved_top_container.dart';

import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../widgets/mobile_input.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with WidgetsBindingObserver {
  final TextEditingController mobileController = TextEditingController();
  final FocusNode mobileFocusNode = FocusNode();

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mobileController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    if (errorMessage != null) {
      setState(() {
        errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mobileController.removeListener(_onTextChanged);
    mobileController.dispose();
    mobileFocusNode.dispose();
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

  void _dismissKeyboard() {
    if (mobileFocusNode.hasFocus) {
      mobileFocusNode.unfocus();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<void> _sendOtp() async {
    _dismissKeyboard();

    final bool hasConnection = await NetworkService.hasInternet();
    if (!hasConnection) {
      setState(() {
        errorMessage = 'No internet connection';
      });
      return;
    }

    String input = mobileController.text.trim();
    if (input.startsWith("+91 ")) {
      input = input.substring(4).trim();
    }

    final error = Validators.validateInput(input);
    if (error != null) {
      setState(() {
        errorMessage = error;
      });
      return;
    }

    setState(() {
      errorMessage = null;
    });

    if (!mounted) return;
    context.read<LoginBloc>().add(
      SendOtpPressed(mobile: input),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            _showLoader(context);
          } else {
            _hideLoader(context);
          }

          if (state is LoginFailure) {
            if (!mounted) return;
            setState(() {
              errorMessage = state.error;
            });
          } else if (state is LoginSuccess) {
            if (!mounted) return;
            context.push(
              RouteNames.otpVerification,
              extra: state.mobile,
            );
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _dismissKeyboard,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
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
                      curve: Curves.easeOut,
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
                      curve: Curves.easeOut,
                      left: -width * 0.36,
                      bottom: isKeyboardVisible ? keyboardHeight - 20 : 0,
                      child: SizedBox(
                        width: width * 1.76,
                        height: height * 0.46,
                        child: CurvedTopContainer(
                          curveHeight: 0.42,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: height * 0.06,
                              left: width * 0.41,
                              right: width * 0.41,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Welcome Back",
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.015,
                                ),

                                if (errorMessage != null &&
                                    errorMessage!.contains(
                                      'No internet connection',
                                    ))
                                  Expanded(
                                    child: NoInternetWidget(
                                      onRetry: () {
                                        setState(() {
                                          errorMessage = null;
                                        });
                                        _sendOtp();
                                      },
                                    ),
                                  )
                                else ...[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 4,
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
                                    focusNode: mobileFocusNode,
                                    errorText: errorMessage,
                                  ),
                                  SizedBox(
                                    height: height * 0.015,
                                  ),
                                  AuthButton(
                                    title: "Send OTP →",
                                    onTap: _sendOtp,
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
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