abstract class LoginEvent {}

class SendOtpPressed extends LoginEvent {
  final String mobile;
  SendOtpPressed({required this.mobile});
}