class GenerateKeyModel {
  final int statusCode;
  final bool success;
  final String keyCode;
  final String message;

  GenerateKeyModel({
    required this.statusCode,
    required this.success,
    required this.keyCode,
    required this.message,
  });

  factory GenerateKeyModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return GenerateKeyModel(
      statusCode: json['statusCode'] ?? 0,
      success: json['success'] ?? false,
      keyCode: data['apiacessKey'] ?? '',
      message: json['message'] ?? '',
    );
  }
}