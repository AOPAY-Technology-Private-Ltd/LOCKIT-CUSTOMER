import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes/route_names.dart';
import '../../../../core/di/injection.dart';

import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashBloc>()
        ..add(
          SplashStarted(),
        ),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashCompleted) {
            context.go(RouteNames.login);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SizedBox.expand(
              child: Image.asset(
                "assets/images/splash.gif",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}