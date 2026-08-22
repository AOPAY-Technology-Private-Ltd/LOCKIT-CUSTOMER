import 'package:flutter_bloc/flutter_bloc.dart';
import 'generate_key_event.dart';
import 'generate_key_state.dart';

class GenerateKeyBloc extends Bloc<GenerateKeyEvent, GenerateKeyState> {
  GenerateKeyBloc() : super(GenerateKeyInitial()) {
    on<RequestGenerateKeyEvent>((event, emit) async {
      emit(GenerateKeyLoading());

      try {
        await Future.delayed(const Duration(seconds: 2));
        const generatedKey = "AOP8 - 9941 - K821 - X902";
        emit(GenerateKeySuccess(keyCode: generatedKey));
      } catch (e) {
        emit(GenerateKeyError(message: e.toString()));
      }
    });
  }
}