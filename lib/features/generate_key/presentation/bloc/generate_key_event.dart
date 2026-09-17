abstract class GenerateKeyEvent {}

class RequestGenerateKeyEvent extends GenerateKeyEvent {}

class RequestValidateKeyEvent extends GenerateKeyEvent {
  final String keyCode;
  RequestValidateKeyEvent({required this.keyCode});
}