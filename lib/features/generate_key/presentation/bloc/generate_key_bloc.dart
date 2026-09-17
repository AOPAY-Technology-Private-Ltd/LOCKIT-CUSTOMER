import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_key_usecase.dart';
import '../../domain/usecases/validate_customer_key_usecase.dart';
import '../../../../core/services/session_manager.dart';
import 'generate_key_event.dart';
import 'generate_key_state.dart';

class GenerateKeyBloc extends Bloc<GenerateKeyEvent, GenerateKeyState> {
  final GenerateKeyUseCase generateKeyUseCase;
  final ValidateCustomerKeyUseCase validateCustomerKeyUseCase;

  GenerateKeyBloc(
      this.generateKeyUseCase,
      this.validateCustomerKeyUseCase,
      ) : super(GenerateKeyInitial()) {

    on<RequestGenerateKeyEvent>((event, emit) async {
      debugPrint("--- [GenerateKeyBloc] Event Received: RequestGenerateKeyEvent ---");
      emit(GenerateKeyLoading());

      try {
        debugPrint("--- [GenerateKeyBloc] Calling GenerateKeyUseCase ---");
        final result = await generateKeyUseCase();

        debugPrint("--- [GenerateKeyBloc] UseCase Success! Key: ${result.keyCode}, IsVerified: ${result.isVerified} ---");
        emit(GenerateKeySuccess(keyCode: result.keyCode, isVerified: result.isVerified));
      } catch (e, stackTrace) {
        debugPrint("--- [GenerateKeyBloc] ERROR CAUGHT: $e ---");
        debugPrint("--- [GenerateKeyBloc] STACKTRACE: $stackTrace ---");
        emit(GenerateKeyError(message: e.toString()));
      }
    });

    on<RequestValidateKeyEvent>((event, emit) async {
      debugPrint("--- [GenerateKeyBloc] Event Received: RequestValidateKeyEvent ---");
      emit(GenerateKeyLoading());

      try {
        debugPrint("--- [GenerateKeyBloc] Calling ValidateCustomerKeyUseCase for Key: ${event.keyCode} ---");
        final bool isVerified = await validateCustomerKeyUseCase(event.keyCode);

        debugPrint("--- [GenerateKeyBloc] Validation Result: $isVerified ---");

        if (isVerified) {
          await SessionManager.setKeyVerified(true);

          emit(GenerateKeyVerifiedState());
        } else {
          emit(GenerateKeyError(message: "Key not verified yet. Please try again."));
        }
      } catch (e, stackTrace) {
        debugPrint("--- [GenerateKeyBloc] ERROR CAUGHT: $e ---");
        debugPrint("--- [GenerateKeyBloc] STACKTRACE: $stackTrace ---");
        emit(GenerateKeyError(message: e.toString()));
      }
    });
  }
}