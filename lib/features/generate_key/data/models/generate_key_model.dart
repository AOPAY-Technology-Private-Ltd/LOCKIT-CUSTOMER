class GenerateKeyModel {
  final String keyCode;
  final String message;

  GenerateKeyModel({required this.keyCode, required this.message});

  factory GenerateKeyModel.fromJson(Map<String, dynamic> json) {
    return GenerateKeyModel(
      keyCode: json['keyCode'] ?? '',
      message: json['message'] ?? '',
    );
  }
}