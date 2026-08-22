import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_key_usecase.dart';

abstract class GenerateKeyEvent {}
class RequestGenerateKeyEvent extends GenerateKeyEvent {}

abstract class GenerateKeyState {}
class GenerateKeyInitial extends GenerateKeyState {}
class GenerateKeyLoading extends GenerateKeyState {}
class GenerateKeySuccess extends GenerateKeyState {
  final String keyCode;
  GenerateKeySuccess({required this.keyCode});
}
class GenerateKeyError extends GenerateKeyState {
  final String message;
  GenerateKeyError({required this.message});
}

class GenerateKeyBloc extends Bloc<GenerateKeyEvent, GenerateKeyState> {
  final GenerateKeyUseCase generateKeyUseCase;

  GenerateKeyBloc(this.generateKeyUseCase) : super(GenerateKeyInitial()) {
    on<RequestGenerateKeyEvent>((event, emit) async {
      emit(GenerateKeyLoading());
      try {
        final result = await generateKeyUseCase();
        emit(GenerateKeySuccess(keyCode: result.keyCode));
      } catch (e) {
        emit(GenerateKeyError(message: e.toString()));
      }
    });
  }
}