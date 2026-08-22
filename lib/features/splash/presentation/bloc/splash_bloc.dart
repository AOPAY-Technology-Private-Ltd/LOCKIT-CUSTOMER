import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/session_manager.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
      SplashStarted event,
      Emitter<SplashState> emit,
      ) async {
    emit(SplashLoading());

    await Future.delayed(const Duration(seconds: 3));

    bool isLoggedIn = await SessionManager.isLoggedIn();

    if (isLoggedIn) {
      emit(SplashNavigateToHome());
    } else {
      emit(SplashCompleted());
    }
  }
}