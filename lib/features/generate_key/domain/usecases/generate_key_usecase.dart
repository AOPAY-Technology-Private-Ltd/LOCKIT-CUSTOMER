import '../entities/generated_key_entity.dart';
import '../repositories/generate_key_repository.dart';

class GenerateKeyUseCase {
  final GenerateKeyRepository repository;

  GenerateKeyUseCase(this.repository);

  Future<GeneratedKeyEntity> call() async {
    return await repository.generateAndValidateKey();
  }
}