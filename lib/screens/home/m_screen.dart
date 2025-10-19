import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/screens/home/home_tabs/call_history_screen.dart';
import 'package:zee_goo/screens/home/call_history_tab/call_history_tab.dart';
import 'package:zee_goo/screens/home/home_tabs/home_screen.dart';
import 'package:zee_goo/screens/home/home_tabs/profile_options/add_coins_screen.dart';
import 'package:zee_goo/screens/home/home_tabs/profile_screen.dart';
import 'package:zee_goo/screens/home/home_tabs/profile_options/wallet_screen.dart';

class MScreen extends ConsumerStatefulWidget {
  const MScreen({super.key});

  @override
  ConsumerState<MScreen> createState() => _MScreenState();
}

class _MScreenState extends ConsumerState<MScreen> with WidgetsBindingObserver {
  int isSelectedIndex = 0;
  List<Widget> isSelected = [
    HomeScreen(),
    // CallHistoryScreen(),
    CallHistoryTab(),
    ProfileScreen(),
  ];

  ////
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setOnline(true); // Set online when app opens
  }

  ////
  @override
  void dispose() {
    _setOnline(false); // Set offline when app is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App in background or closed
      _setOnline(false);
    } else if (state == AppLifecycleState.resumed) {
      // App resumed
      _setOnline(true);
    }
  }

  Future<void> _setOnline(bool online) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'isOnline': online});
    }
  }

  void onTaped(int index) {
    setState(() {
      isSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 221, 221, 221),
      appBar: AppBar(
        title: Text(
          AppConstants.APP_NAME,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 29, 28, 28),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              if (currentUser == null) {
                return Text("Not logged in");
              }
              final userData = ref.watch(userDataProvider(currentUser.uid));
              return userData.when(
                data: (data) {
                  return InkWell(
                    onTap: () {
                      if (data.gender == "Male") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddCoinsScreen(userId: data.uid),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WalletScreen(userId: data.uid),
                          ),
                        );
                      }
                    },
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        child: Row(
                          children: [
                            data.gender == "Male"
                                ? Image.asset(
                                    'assets/images/dollar.png',
                                    height: 23.h,
                                    width: 23.w,
                                  )
                                : Text(
                                    "₹",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                        255,
                                        243,
                                        208,
                                        10,
                                      ),
                                    ),
                                  ),
                            SizedBox(width: 5.w),
                            Text(
                              data.balance.toStringAsFixed(2),
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                error: (err, _) => Text(err.toString()),
                loading: () => Center(child: CircularProgressIndicator()),
              );
            },
          ),
          SizedBox(width: 15.w),
        ],
      ),
      body: isSelected[isSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: isSelectedIndex,
        onTap: onTaped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepOrange,
        items: [
          BottomNavigationBarItem(icon: Icon(Iconsax.home_2), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.transaction_minus5),
            label: "Calls History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.profile_circle5),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
