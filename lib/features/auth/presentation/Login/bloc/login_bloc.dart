import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/send_otp_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  final SendOtpUseCase sendOtpUseCase;

  LoginBloc({
    required this.loginUseCase,
    required this.sendOtpUseCase,
  }) : super(LoginInitial()) {
    on<SendOtpPressed>(_sendOtp);
  }

  Future<void> _sendOtp(SendOtpPressed event, Emitter<LoginState> emit) async {
    String input = event.mobile.trim();
    if (input.startsWith("+91 ")) input = input.substring(4).trim();
    final isMobile = RegExp(r'^[0-9]{10}$').hasMatch(input);
    final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);

    if (input.isEmpty) {
      emit(LoginFailure(error: "Mobile Number or Email is mandatory."));
      return;
    }

    if (!isMobile && !isEmail) {
      emit(LoginFailure(error: "Please enter a valid 10-digit number or email."));
      return;
    }

    emit(LoginLoading());
    try {
      await loginUseCase(
        mobileOrEmailID: input,
      );

      final result = await sendOtpUseCase(input);

      emit(
        LoginSuccess(
          mobile: input,
          message: result.message,
        ),
      );
    } catch (e) {
      String rawError = e.toString().replaceAll("Exception: ", "");

      String errorMessage;
      if (rawError.contains('No internet connection') ||
          rawError.contains('SocketException') ||
          rawError.contains('Failed host lookup')) {
        errorMessage = 'No internet connection. Please check your network settings.';
      } else {
        errorMessage = rawError;
      }

      emit(LoginFailure(error: errorMessage));
    }
  }
}