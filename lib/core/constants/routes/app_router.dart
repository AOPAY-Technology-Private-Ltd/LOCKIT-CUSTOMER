import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/presentation/Login/bloc/login_bloc.dart';
import '../../../features/auth/presentation/Login/pages/login_page.dart';
import '../../../features/auth/presentation/verifyotp/bloc/otp_bloc.dart';
import '../../../features/auth/presentation/verifyotp/pages/otp_verification_view.dart';
import '../../../features/generate_key/presentation/bloc/generate_key_bloc.dart';
import '../../../features/generate_key/presentation/pages/generate_key_page.dart';
import '../../../features/generate_key/presentation/security_key_view/pages/security_key_vew.dart';
import '../../../features/profile/presentation/bloc/profile_bloc.dart' show ProfileBloc;
import '../../../features/profile/presentation/bloc/profile_event.dart';
import '../../../features/profile/presentation/pages/profile_view.dart';
import '../../../features/profile/presentation/pages/DeviceLockScreen.dart'; // Lock screen import
import '../../di/injection.dart';
import 'route_names.dart';
import '../../../features/splash/presentation/pages/splash_page.dart';

// 🔥 Global Navigator Key yahan define ki hai taaki har jagah access ho sake
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey, // 🔥 GoRouter ke sath key bind karna zaroori hai!
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<LoginBloc>(),
          child: const LoginView(),
        ),
      ),

      GoRoute(
        path: RouteNames.otpVerification,
        name: RouteNames.otpVerification,
        builder: (context, state) {
          final mobile = state.extra as String? ?? '';
          return BlocProvider(
            create: (_) => sl<OtpBloc>(),
            child: OtpVerificationView(mobile: mobile),
          );
        },
      ),

      GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profile,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProfileBloc>()..add(LoadProfileEvent()),
          child: const ProfileView(),
        ),
      ),

      GoRoute(
        path: RouteNames.generateKey,
        name: RouteNames.generateKey,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<GenerateKeyBloc>(),
          child: const GenerateKeyView(),
        ),
      ),

      GoRoute(
        path: RouteNames.securityKey,
        name: RouteNames.securityKey,
        builder: (context, state) {
          final String? key = state.extra as String?;
          return BlocProvider(
            create: (_) => sl<GenerateKeyBloc>(),
            child: SecurityKeyView(initialKey: key),
          );
        },
      ),

      // Optional: Agar lock screen ko route ke through bhi rakhna ho
      GoRoute(
        path: '/device-lock',
        builder: (context, state) => const DeviceLockScreen(),
      ),
    ],
  );
}

class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String otpVerification = '/otp-verification';
  static const String profile = '/profile';
  static const String generateKey = '/generate-key';
  static const String securityKey = '/security-key';
}