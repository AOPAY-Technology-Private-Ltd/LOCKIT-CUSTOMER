class ApiConstants {
  static const String mainBaseUrl = 'https://uatapi.aopay.co.in';
  static const String smsBaseUrl = 'http://web.adcruxmedia.in';


  static const String Login = '$mainBaseUrl/api/V1/AopayFinance/Login';

  static const String sendOtp = '$mainBaseUrl/api/V1/AopayFinance/SendOTP';


  static const String kitVerifyOtp = '$mainBaseUrl/api/V1/AopayFinance/KitVerifyOTP';


  static const String getUpdateCustomerKitProfile = '$mainBaseUrl/api/V1/AopayFinance/GetUpdateCustomerKitProfile';

  static const String generateKeyApi = '$mainBaseUrl/api/V1/AopayFinance/generatekey';




  static const String sendSms = '$smsBaseUrl/vb/apikey.php';
}

