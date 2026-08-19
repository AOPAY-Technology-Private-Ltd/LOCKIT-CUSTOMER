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
    return UserProfileModel(
      name: json['name'] ?? '',
      tier: json['tier'] ?? '',
      initials: json['initials'] ?? '',
      dob: json['dob'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      panCard: json['panCard'] ?? '',
      aadharCard: json['aadharCard'] ?? '',
      imei1: json['imei1'] ?? '',
      imei2: json['imei2'] ?? '',
    );
  }
}