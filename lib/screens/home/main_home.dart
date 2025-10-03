// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:zee_goo/repository/auth_repository.dart';
// import 'package:zee_goo/screens/Login/login_page.dart';
// import 'package:zee_goo/providers/User/user_provider.dart';
// import 'package:zee_goo/screens/call/video_audio_call_button.dart';
// // Import updated actionButton

// class HomeScreen extends ConsumerWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final allUsersAsync = ref.watch(allUserProvider);
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       // Redirect if not logged in
//       Future.microtask(() {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const LoginScreen()),
//         );
//       });
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 231, 230, 230),
//       appBar: AppBar(
//         title: Text("Hey, ${currentUser.displayName ?? currentUser.email}"),
//         backgroundColor: Colors.orange,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await AuthService().signOut();
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LoginPage()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: allUsersAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text("Error: $e")),
//         data: (users) {
//           // Filter out current user
//           final filteredUsers = users
//               .where((user) => user.uid != currentUser.uid)
//               .toList();

//           if (filteredUsers.isEmpty) {
//             return const Center(child: Text("No other users found"));
//           }

//           return ListView.builder(
//             itemCount: filteredUsers.length,
//             itemBuilder: (context, index) {
//               final user = filteredUsers[index];

//               return Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
//                 child: Card(
//                   color: Colors.white,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 5.w,
//                       vertical: 15.h,
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Image.asset(
//                           'assets/images/userimage.png',
//                           fit: BoxFit.cover,
//                           height: 100.h,
//                           width: 100.w,
//                         ),
//                         SizedBox(height: 5.h),
//                         Text(user.name),
//                         SizedBox(height: 5.h),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             // Audio Call
//                             actionButton(
//                               isVideo: false,
//                               receiverId: user.uid,
//                               receiverName: user.name,
//                             ),
//                             SizedBox(width: 20.w),
//                             // Video Call
//                             actionButton(
//                               isVideo: true,
//                               receiverId: user.uid,
//                               receiverName: user.name,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
