import '../entities/entities.dart';

abstract class AuthRepository {
  Future<AuthEntity> login({
    required String mobileOrEmailID,
  });

  Future<AuthEntity> sendOtp(String mobile);

  Future<AuthEntity> verifyOtp({
    required String mobileOrEmail,
    required String otp,
  });
}