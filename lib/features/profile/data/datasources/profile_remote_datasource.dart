import '../models/user_profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<UserProfileModel> fetchUserProfile();
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {


  @override
  Future<UserProfileModel> fetchUserProfile() async {

    await Future.delayed(const Duration(seconds: 1));

    return const UserProfileModel(
      name: "Tarun Kumar",
      tier: "Standard Security Tier",
      initials: "TK",
      dob: "14 Apr 1998",
      mobile: "+91 98765 43210",
      email: "tarun.kumar@gmail.com",
      address: "Sector 95B, Gurgaon, Haryana - 122505, India",
      panCard: "ABCDE1234F",
      aadharCard: "1234 5678 9012",
      imei1: "862345678901234",
      imei2: "862345678901235",
    );
  }
}