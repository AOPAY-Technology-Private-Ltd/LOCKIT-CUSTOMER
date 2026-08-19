class SmsResponseModel {
  final bool success;
  final String message;

  SmsResponseModel({required this.success, required this.message});

  factory SmsResponseModel.fromJson(Map<String, dynamic> json) {
    return SmsResponseModel(
      success: json['success'] ?? true,
      message: json['message'] ?? "SMS Sent",
    );
  }
}