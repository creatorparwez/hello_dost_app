import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalUsersOption/total_users_screen.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/providers/User/user_provider.dart';

class Admindashboard extends ConsumerStatefulWidget {
  const Admindashboard({super.key});

  @override
  ConsumerState<Admindashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Admindashboard> {
  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersProvider);
    final allCallsAsync = ref.watch(allCallHistoryProvider);

    final allUsersLength = allUsersAsync.when(
      data: (users) => users.length.toString(),
      loading: () => '0',
      error: (err, stack) => '0',
    );

    final allCallsLength = allCallsAsync.when(
      data: (calls) => calls.length.toString(),
      loading: () => '0',
      error: (err, stack) => '0',
    );

    return Scaffold(
      backgroundColor: AppConstants.appsecondaryColor,
      appBar: AppBar(
        title: Text(
          "${AppConstants.APP_NAME} Admin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 makes the drawer icon white
        ),
        backgroundColor: const Color(0xFF141D3C),
      ),
      // Drawer Section
      drawer: _buildDrawerSection(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Column(
          children: [
            // Total Users Section
            _dashbordSections(
              title: "Total Users",
              lenght: allUsersLength,
              iconss: Icons.person,
            ),
            SizedBox(height: 10.h),
            // Total Calls Section
            _dashbordSections(
              title: "Total Calls",
              lenght: allCallsLength,
              iconss: Icons.call,
            ),
          ],
        ),
      ),
    );
  }
}

// Drawer Section
class _buildDrawerSection extends StatelessWidget {
  const _buildDrawerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF141D3C),
        child: Column(
          children: [
            DrawerHeader(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 65.r,
                child: Image.asset(
                  'assets/admin/admin.png',
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Dashboard
            ListTile(
              onTap: () {
                // Navigate Back
                Navigator.pop(context);
              },
              leading: Icon(Iconsax.home, size: 30.sp, color: Colors.white),
              title: Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            // Total Users
            ListTile(
              onTap: () {
                // Navigate to Total Users Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TotalUsersScreen()),
                );
              },

              leading: Icon(Iconsax.user, size: 30.sp, color: Colors.white),
              title: Text(
                "Total Users",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              selected: true,

              selectedTileColor: Colors.white,
            ),
            // Total Calls
            ListTile(
              onTap: () {
                // Navigate to Total Calls Screen
              },
              leading: Icon(Iconsax.call, size: 30.sp, color: Colors.white),
              title: Text(
                "Total Calls",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.h),
              child: Divider(thickness: 1, color: Colors.white),
            ),
            // Total Calls
            ListTile(
              onTap: () {
                // Navigate to Total Users Screen
              },
              leading: Icon(Iconsax.logout, size: 30.sp, color: Colors.white),
              title: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dashboard Sections
class _dashbordSections extends StatelessWidget {
  const _dashbordSections({
    required this.lenght,
    required this.title,
    required this.iconss,
  });

  final String lenght;
  final String title;
  final IconData iconss;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 50.w, top: 30.h, bottom: 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 95, 95, 95),
              ),
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                Icon(
                  iconss,
                  size: 28.sp,
                  color: const Color.fromARGB(255, 119, 119, 119),
                ),
                SizedBox(width: 6.w),
                Text(
                  lenght,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 119, 119, 119),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
