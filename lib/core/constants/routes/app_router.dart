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
import '../../di/injection.dart';
import 'route_names.dart';
import '../../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
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

      // GoRoute(
      //   path: RouteNames.home,
      //   name: RouteNames.home,
      //   builder: (context, state) => const HomePage(),
      // ),
    ],
  );
}