import '../entities/entities.dart';

abstract class AuthRepository {
  Future<AuthEntity> login({
    required String mobileOrEmailID,
    String password = "",
    String loginType = "Customer",
  });

  Future<AuthEntity> sendOtp(String mobileOrEmail);

  Future<AuthEntity> kitVerifyOtp({
    required String mobileOrEmail,
    required String otp,
  });
}