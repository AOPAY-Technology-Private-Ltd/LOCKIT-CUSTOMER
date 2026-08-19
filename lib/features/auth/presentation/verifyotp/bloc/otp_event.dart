import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

class VerifyOtpPressed extends OtpEvent {
  final String mobileOrEmail;
  final String otp;
  final bool isLogin;

  const VerifyOtpPressed({
    required this.mobileOrEmail,
    required this.otp,
    this.isLogin = false,
  });

  @override
  List<Object?> get props => [
    mobileOrEmail,
    otp,
    isLogin,
  ];
}

class ResendOtpPressed extends OtpEvent {
  final String mobileOrEmail;

  const ResendOtpPressed({
    required this.mobileOrEmail,
  });

  @override
  List<Object?> get props => [
    mobileOrEmail,
  ];
}