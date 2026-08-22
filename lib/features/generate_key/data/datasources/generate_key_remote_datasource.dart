import '../models/generate_key_model.dart';

abstract class GenerateKeyRemoteDataSource {
  Future<GenerateKeyModel> generateKeyApi();
}

class GenerateKeyRemoteDataSourceImpl implements GenerateKeyRemoteDataSource {
  @override
  Future<GenerateKeyModel> generateKeyApi() async {
    await Future.delayed(const Duration(seconds: 2));

    return GenerateKeyModel(
      keyCode: "LOCKIT-KEY-9876-XYZ",
      message: "Key generated successfully",
    );
  }
}