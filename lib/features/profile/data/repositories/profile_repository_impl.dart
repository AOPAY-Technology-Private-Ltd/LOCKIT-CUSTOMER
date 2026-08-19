import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDatasource;

  ProfileRepositoryImpl(this.remoteDatasource);

  @override
  Future<UserProfileEntity> getUserProfile() async {
    return const UserProfileEntity(
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