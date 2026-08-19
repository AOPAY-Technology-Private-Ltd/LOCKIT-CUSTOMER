import '../entities/entities.dart';
import '../repositories/auth_repository.dart';


class SendOtpUseCase {

  final AuthRepository repository;


  SendOtpUseCase(
      this.repository,
      );


  Future<AuthEntity> call(
      String mobile,
      ) async {

    return await repository.sendOtp(
      mobile,
    );

  }

}