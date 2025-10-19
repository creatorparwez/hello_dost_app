import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/repository/auth_repository.dart';
import 'package:zee_goo/screens/home/home_tabs/profile_options/account_settings/blocked_users_widget.dart';

class AccountSettings extends StatefulWidget {
  final String gender;
  final String userId;
  final List<String> blockedUserIds;
  const AccountSettings({
    super.key,
    required this.userId,
    required this.blockedUserIds,
    required this.gender,
  });

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  final AuthRepository _authRepository = AuthRepository();
  late List<String> blockedUserIds;

  @override
  void initState() {
    super.initState();
    blockedUserIds = widget.blockedUserIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Settings", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 29, 28, 28),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 15.h),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            // Blocked Users
            widget.gender == "Female"
                ? _buildSections(
                    icon: Icons.warning,
                    title: "Blocked Users",
                    onTap: () async {
                      // Blocked Users List
                      print("Blocked Usersssss :   $blockedUserIds");
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlockedUsersWidget(
                            currentUserId: widget.userId,
                            blockedUserIds: blockedUserIds,
                          ),
                        ),
                      );

                      // Update the blocked users list if result is returned
                      if (result != null && result is List<String>) {
                        setState(() {
                          blockedUserIds = result;
                        });
                        print("Updated Blocked Users: $blockedUserIds");
                      }
                    },
                  )
                : SizedBox.shrink(),
            SizedBox(height: 6.h),
            // Delete Account
            _buildSections(
              icon: Icons.delete,
              title: "Delete Account",
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Are you sure you want to delete your account?",
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      actionsPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      actions: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 10.w,
                            right: 10.w,
                            bottom: 20.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // ❌ No Button
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      55,
                                      13,
                                      240,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    "No",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),

                              // ✅ Yes Button
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),

                                  child: Text(
                                    "Yes",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _buildSections extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _buildSections({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
            left: 60.w,
            top: 10.h,
            bottom: 10.h,
            right: 40.w,
          ),
          child: Row(
            children: [
              Icon(icon, size: 33.sp),
              SizedBox(width: 15.w),
              Text(
                title,
                style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Text(
                ">",
                style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
