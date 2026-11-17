class ApiConstants {

  static const String devBaseUrl = 'https://dev.uatapi.aopay.co.in';
  static const String uatBaseUrl = 'https://uatapi.aopay.co.in';
  static const String stagingBaseUrl = 'https://uat.api.aopay.finance';
  static const String prodBaseUrl = 'https://api.aopay.finance';

  static const String smsBaseUrl = 'http://web.adcruxmedia.in';

  static Environment currentEnvironment = Environment.dev;

  static String get mainBaseUrl {
    switch (currentEnvironment) {
      case Environment.dev:
        return devBaseUrl;
      case Environment.uat:
        return uatBaseUrl;
      case Environment.staging:
        return stagingBaseUrl;
      case Environment.prod:
        return prodBaseUrl;
    }
  }

  static String get login => '$mainBaseUrl/api/V1/AopayFinance/AppLoan/Login';

  static String get sendOtp => '$mainBaseUrl/api/V1/AopayFinance/SendOTP';

  static String get kitVerifyOtp => '$mainBaseUrl/api/V1/AopayFinance/KitVerifyOTP';

  static String get getUpdateCustomerKitProfile => '$mainBaseUrl/api/V1/AopayFinance/GetUpdateCustomerKitProfile';

  static String get generateKeyApi => '$mainBaseUrl/api/V1/AopayFinance/generatekey';

  static String get saveCustomerLocationKit => '$mainBaseUrl/api/V1/AopayFinance/SaveCustomerLocationKit';

  static String get validateCustomerKey => '$mainBaseUrl/api/V1/AopayFinance/customervalidatekey';

  static String get appMasterService => '$mainBaseUrl/api/notification/SaveAppMaster';

  static String get deviceInformationService => '$mainBaseUrl/api/V1/AopayFinance/GetDeviceInformation';

  static String get pendingActionService => '$mainBaseUrl/api/notification/GetPendingDeviceActions';

  static String get appUninstalledService => '$mainBaseUrl/api/notification/CustomerAppUninstalled';

  static const String sendSms = '$smsBaseUrl/vb/apikey.php';



  static String get updateDeviceActionStatus => '$mainBaseUrl/api/notification/UpdateDeviceActionStatus';

}

enum Environment {
  dev,
  uat,
  staging,
  prod,
}