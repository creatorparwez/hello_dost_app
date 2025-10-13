import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/providers/User/user_provider.dart';

class ApprovalWidget extends ConsumerStatefulWidget {
  const ApprovalWidget({super.key});

  @override
  ConsumerState<ApprovalWidget> createState() => _ApprovalWidgetState();
}

class _ApprovalWidgetState extends ConsumerState<ApprovalWidget> {
  String searchQuery = '';
  final Set<String> loadingUsers = {}; // Track per-user loading

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersProvider);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Search female user by name or phone",
              prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
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

        // User List
        Expanded(
          child: allUsersAsync.when(
            data: (allUsersData) {
              final femaleUsers = allUsersData
                  .where(
                    (user) =>
                        user.gender?.toLowerCase() == "female" &&
                        user.permission == false,
                  )
                  .toList();

              final filteredUsers = femaleUsers.where((user) {
                final name = user.name.toLowerCase();
                final phone = user.phone?.toLowerCase() ?? '';
                return name.contains(searchQuery) ||
                    phone.contains(searchQuery);
              }).toList();

              // Sort by latest
              filteredUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              if (filteredUsers.isEmpty) {
                return const Center(
                  child: Text(
                    "No female users pending permission",
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
                  final isUserLoading = loadingUsers.contains(user.uid);

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(
                        Icons.female,
                        color: Colors.pinkAccent,
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
                      trailing: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: isUserLoading
                            ? null
                            : () async {
                                setState(() => loadingUsers.add(user.uid));
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({'permission': true});
                                setState(() => loadingUsers.remove(user.uid));
                              },
                        child: isUserLoading
                            ? SizedBox(
                                width: 20.sp,
                                height: 20.sp,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Approve",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
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
