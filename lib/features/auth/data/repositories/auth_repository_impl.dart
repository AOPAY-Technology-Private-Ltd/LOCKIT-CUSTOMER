import '../../domain/entities/entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl({required this.datasource});

  @override
  Future<AuthEntity> login({
    required String mobileOrEmailID,
    String password = "",
    String loginType = "Customer",
  }) async {
    return await datasource.login(
      mobileOrEmailID: mobileOrEmailID,
      password: password,
      loginType: loginType,
    );
  }

  @override
  Future<AuthEntity> sendOtp(String mobileOrEmailID) async {
    return await datasource.sendOtp(mobileOrEmailID);
  }

  @override
  Future<AuthEntity> kitVerifyOtp({
    required String mobileOrEmail,
    required String otp,
  }) async {
    return await datasource.kitVerifyOtp(
      mobileOrEmail: mobileOrEmail,
      otp: otp,
    );
  }
}