import '../../domain/entities/entities.dart';

class LoginResponseModel extends AuthEntity {
  final String? customerCode;
  final String? retailerCode;
  final String? firstName;
  final String? lastName;
  final String? mobileNo;
  final String? emailID;
  final String? address;
  final String? aadharNumber;
  final String? panNumber;
  final String? activeStatus;

  LoginResponseModel({
    required String message,
    this.customerCode,
    this.retailerCode,
    this.firstName,
    this.lastName,
    this.mobileNo,
    this.emailID,
    this.address,
    this.aadharNumber,
    this.panNumber,
    this.activeStatus,
  }) : super(message: message);

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] ?? "",
      customerCode: json['customerCode'] ?? json['value'],
      retailerCode: json['retailerCode'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      mobileNo: json['mobileNo'],
      emailID: json['emailID'],
      address: json['address'],
      aadharNumber: json['aadharNumber'],
      panNumber: json['panNumber'],
      activeStatus: json['activeStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "customerCode": customerCode,
      "retailerCode": retailerCode,
      "firstName": firstName,
      "lastName": lastName,
      "mobileNo": mobileNo,
      "emailID": emailID,
      "address": address,
      "aadharNumber": aadharNumber,
      "panNumber": panNumber,
      "activeStatus": activeStatus,
    };
  }
}