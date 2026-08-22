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