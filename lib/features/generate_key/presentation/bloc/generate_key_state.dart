abstract class GenerateKeyState {}

class GenerateKeyInitial extends GenerateKeyState {}

class GenerateKeyLoading extends GenerateKeyState {}

class GenerateKeySuccess extends GenerateKeyState {
  final String keyCode;
  final bool isVerified;

  GenerateKeySuccess({required this.keyCode, required this.isVerified});

  @override
  String toString() => 'GenerateKeySuccess(keyCode: $keyCode, isVerified: $isVerified)';
}

class GenerateKeyVerifiedState extends GenerateKeyState {
  @override
  String toString() => 'GenerateKeyVerifiedState';
}

class GenerateKeyError extends GenerateKeyState {
  final String message;
  GenerateKeyError({required this.message});

  @override
  String toString() => 'GenerateKeyError(message: $message)';
}