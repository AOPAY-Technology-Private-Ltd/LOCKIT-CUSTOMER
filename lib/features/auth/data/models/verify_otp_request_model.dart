class VerifyOtpRequestModel {
  final String mobileOrEmail;
  final String enteredOTP;

  VerifyOtpRequestModel({
    required this.mobileOrEmail,
    required this.enteredOTP,
  });

  Map<String, dynamic> toJson() {
    return {
      "mobileOrEmail": mobileOrEmail,
      "enteredOTP": enteredOTP,
    };
  }
}