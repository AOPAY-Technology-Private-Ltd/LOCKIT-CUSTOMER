import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes/route_names.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/network/network_service.dart';
import '../../../auth/presentation/common/widgets/no_internet_widget.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_info_tile.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInternetAndLoadProfile();
  }

  Future<void> _checkInternetAndLoadProfile() async {
    final bool hasConnection = await NetworkService.hasInternet();
    setState(() {
      _hasInternet = hasConnection;
    });

    if (hasConnection && mounted) {
      context.read<ProfileBloc>().add(LoadProfileEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF2563EB),
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ),
        ),
        title: const Text(
          "LockKit",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.logout, color: Colors.red, size: 18),
              label: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              onPressed: () async {
                await SessionManager.clearSession();
                if (context.mounted) {
                  context.go(RouteNames.login);
                }
              },
            ),
          ),
        ],
      ),
      body: !_hasInternet
          ? Center(
        child: NoInternetWidget(
          onRetry: _checkInternetAndLoadProfile,
        ),
      )
          : BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _checkInternetAndLoadProfile,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProfileLoaded) {
            final profile = state.profile;

            return LayoutBuilder(
              builder: (context, constraints) {
                double contentWidth = constraints.maxWidth > 600 ? 550 : constraints.maxWidth;

                return Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          "My Details",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "View your personal and device details",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFF4F46E5),
                                child: Text(
                                  profile.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      profile.tier,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF2563EB),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        ProfileInfoSection(
                          title: "PERSONAL INFO",
                          children: [
                            ProfileInfoTile(
                              icon: Icons.person_outline,
                              title: "Full Name",
                              value: profile.name,
                            ),
                            ProfileInfoTile(
                              icon: Icons.calendar_today_outlined,
                              title: "Date of Birth",
                              value: profile.dob,
                              showDivider: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        ProfileInfoSection(
                          title: "CONTACT DETAILS",
                          children: [
                            ProfileInfoTile(
                              icon: Icons.phone_outlined,
                              title: "Mobile Number",
                              value: profile.mobile,
                            ),
                            ProfileInfoTile(
                              icon: Icons.email_outlined,
                              title: "Email Address",
                              value: profile.email,
                              showDivider: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        ProfileInfoSection(
                          title: "REGISTERED ADDRESS",
                          children: [
                            ProfileInfoTile(
                              icon: Icons.location_on_outlined,
                              title: "Address",
                              value: profile.address,
                              showDivider: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        ProfileInfoSection(
                          title: "DOCUMENTS & DEVICE STATUS",
                          children: [
                            ProfileInfoTile(
                              icon: Icons.badge_outlined,
                              title: "PAN Card",
                              value: profile.panCard,
                            ),
                            ProfileInfoTile(
                              icon: Icons.verified_user_outlined,
                              title: "Aadhar Card",
                              value: profile.aadharCard,
                            ),
                            ProfileInfoTile(
                              icon: Icons.phone_android_outlined,
                              title: "Mobile IMEI Number 1",
                              value: profile.imei1,
                            ),
                            ProfileInfoTile(
                              icon: Icons.phone_android_outlined,
                              title: "Mobile IMEI Number 2",
                              value: profile.imei2,
                              showDivider: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}