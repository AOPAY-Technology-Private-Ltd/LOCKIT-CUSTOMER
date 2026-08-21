import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.name,
    required super.tier,
    required super.initials,
    required super.dob,
    required super.mobile,
    required super.email,
    required super.address,
    required super.panCard,
    required super.aadharCard,
    required super.imei1,
    required super.imei2,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] ?? '';
    final lastName = json['lastName'] ?? '';
    final fullName = "$firstName $lastName".trim();

    String initials = "U";
    if (fullName.isNotEmpty) {
      List<String> nameSplit = fullName.split(' ');
      if (nameSplit.length > 1) {
        initials = "${nameSplit[0][0]}${nameSplit[1][0]}".toUpperCase();
      } else if (nameSplit.isNotEmpty) {
        initials = nameSplit[0][0].toUpperCase();
      }
    }

    String parseValue(dynamic val, String fallback) {
      if (val == null || val.toString().trim().isEmpty || val.toString() == "null") {
        return fallback;
      }
      return val.toString();
    }

    return UserProfileModel(
      name: fullName.isEmpty ? "User" : fullName,
      tier: parseValue(json['customerType'], "Standard Security Tier"),
      initials: initials,
      dob: parseValue(json['dob'], "Not Provided"),
      mobile: parseValue(json['mobileNo'], "Not Provided"),
      email: parseValue(json['emailid'], "Not Provided"),
      address: parseValue(json['address'], "Not Provided"),
      panCard: parseValue(json['panNumber'], "Not Provided"),
      aadharCard: parseValue(json['aadharNumber'], "Not Provided"),
      imei1: parseValue(json['imei1'], "Not Provided"),
      imei2: parseValue(json['imei2'], "Not Provided"),
    );
  }
}