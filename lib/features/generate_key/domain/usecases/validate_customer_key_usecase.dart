import '../repositories/generate_key_repository.dart';

class ValidateCustomerKeyUseCase {
  final GenerateKeyRepository repository;

  ValidateCustomerKeyUseCase(this.repository);

  Future<bool> call(String apiAccessKey) async {
    return await repository.validateCustomerKey(apiAccessKey);
  }
}