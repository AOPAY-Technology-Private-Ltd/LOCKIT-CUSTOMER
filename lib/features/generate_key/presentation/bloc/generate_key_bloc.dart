import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_key_usecase.dart';
import 'generate_key_event.dart';
import 'generate_key_state.dart';

class GenerateKeyBloc extends Bloc<GenerateKeyEvent, GenerateKeyState> {
  final GenerateKeyUseCase generateKeyUseCase;

  GenerateKeyBloc(this.generateKeyUseCase) : super(GenerateKeyInitial()) {
    on<RequestGenerateKeyEvent>((event, emit) async {
      debugPrint("--- [GenerateKeyBloc] Event Received: RequestGenerateKeyEvent ---");
      emit(GenerateKeyLoading());

      try {
        debugPrint("--- [GenerateKeyBloc] Calling GenerateKeyUseCase ---");
        final result = await generateKeyUseCase();

        debugPrint("--- [GenerateKeyBloc] UseCase Success! Key: ${result.keyCode} ---");
        emit(GenerateKeySuccess(keyCode: result.keyCode));
      } catch (e, stackTrace) {
        debugPrint("--- [GenerateKeyBloc] ERROR CAUGHT: $e ---");
        debugPrint("--- [GenerateKeyBloc] STACKTRACE: $stackTrace ---");
        emit(GenerateKeyError(message: e.toString()));
      }
    });
  }
}