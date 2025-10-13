import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/providers/User/user_provider.dart';

class TotalUserWidget extends ConsumerStatefulWidget {
  const TotalUserWidget({super.key});

  @override
  ConsumerState<TotalUserWidget> createState() => _TotalUserState();
}

class _TotalUserState extends ConsumerState<TotalUserWidget> {
  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersProvider);

    final allUsersLength = allUsersAsync.when(
      data: (users) => users.length.toString(),
      loading: () => '0',
      error: (err, stack) => '0',
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 50.w, top: 30.h, bottom: 30.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Users",
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
                    Icons.person_2_sharp,
                    size: 28.sp,
                    color: const Color.fromARGB(255, 119, 119, 119),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    allUsersLength,
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
      ),
    );
  }
}
