import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/network/network_service.dart';

import '../../../../core/constants/routes/route_names.dart';
import '../../../auth/presentation/common/widgets/auth_button.dart';
import '../../../auth/presentation/common/widgets/auth_footer.dart';
import '../../../auth/presentation/common/widgets/auth_image_slider.dart';
import '../../../auth/presentation/common/widgets/auth_logo.dart';
import '../../../auth/presentation/common/widgets/curved_top_container.dart';
import '../../../auth/presentation/common/widgets/no_internet_widget.dart';

class GenerateKeyView extends StatefulWidget {
  const GenerateKeyView({super.key});

  @override
  State<GenerateKeyView> createState() => _GenerateKeyViewState();
}

class _GenerateKeyViewState extends State<GenerateKeyView> with WidgetsBindingObserver {
  String? errorMessage;

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

    context.pushNamed(RouteNames.securityKey);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
                            top: height * 0.09,
                            left: width * 0.41,
                            right: width * 0.41,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Create Your Security Key",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff2563EB),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              Text(
                                "Generate a unique key to activate LocKit.",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: height * 0.02,
                              ),
                              if (errorMessage != null &&
                                  errorMessage!.contains('No internet connection'))
                                SizedBox(
                                  height: 100,
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
                                if (errorMessage != null) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      errorMessage!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 14),
                                AuthButton(
                                  title: "Generate Key →",
                                  onTap: _onGenerateKeyClicked,
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
    );
  }
}