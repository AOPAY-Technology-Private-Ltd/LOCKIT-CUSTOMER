import '../../domain/entities/generated_key_entity.dart';
import '../../domain/repositories/generate_key_repository.dart';
import '../datasources/generate_key_remote_datasource.dart';

class GenerateKeyRepositoryImpl implements GenerateKeyRepository {
  final GenerateKeyRemoteDataSource remoteDataSource;

  GenerateKeyRepositoryImpl(this.remoteDataSource);

  @override
  Future<GeneratedKeyEntity> generateKey() async {
    final model = await remoteDataSource.generateKeyApi();
    return GeneratedKeyEntity(
      keyCode: model.keyCode,
      message: model.message,
    );
  }
}