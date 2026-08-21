import '../../domain/entities/entities.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);
  Future<AuthEntity> call({
    required String mobileOrEmailID,
  }) async {
    return await repository.login(
      mobileOrEmailID: mobileOrEmailID,
    );
  }
}