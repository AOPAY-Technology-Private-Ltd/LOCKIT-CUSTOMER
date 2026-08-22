import '../entities/generated_key_entity.dart';

abstract class GenerateKeyRepository {
  Future<GeneratedKeyEntity> generateKey();
}