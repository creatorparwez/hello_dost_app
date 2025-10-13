import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalUsersOption/user_details_screen.dart';
import 'package:zee_goo/providers/User/user_provider.dart';

class AllUsersWidget extends ConsumerStatefulWidget {
  const AllUsersWidget({super.key});

  @override
  ConsumerState<AllUsersWidget> createState() => _AllUsersWidgetState();
}

class _AllUsersWidgetState extends ConsumerState<AllUsersWidget> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersProvider);

    return Column(
      children: [
        // 🔹 Search Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Search user by name or phone",
              prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() => searchQuery = value.toLowerCase());
            },
          ),
        ),

        // 🔹 User List
        Expanded(
          child: allUsersAsync.when(
            data: (allUsersData) {
              // Filter users based on search
              final filteredUsers = allUsersData.where((user) {
                final name = user.name.toLowerCase();
                final phone = user.phone?.toLowerCase() ?? '';
                return name.contains(searchQuery) ||
                    phone.contains(searchQuery);
              }).toList();

              if (filteredUsers.isEmpty) {
                return const Center(
                  child: Text(
                    "No users found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                itemCount: filteredUsers.length,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  var user = filteredUsers[index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Colors.deepOrange,
                        size: 35.sp,
                      ),
                      title: Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        user.phone ?? "No phone",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      trailing: Text(
                        user.gender ?? "N/A",
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[800],
                        ),
                      ),
                      onTap: () {
                        // Navigate to user detail screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserDetailsScreen(
                              userId: user.uid,
                              userName: user.name,
                              gender: user.gender.toString(),
                              phone: user.phone.toString(),
                              balance: user.balance,
                              age: user.age.toString(),
                              languages: user.languages,
                              interests: user.interests,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            error: (err, _) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
