import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:zee_goo/providers/User/user_provider.dart';

class WeekCallsWidget extends ConsumerStatefulWidget {
  const WeekCallsWidget({super.key});

  @override
  ConsumerState<WeekCallsWidget> createState() => _WeekCallsWidgetState();
}

class _WeekCallsWidgetState extends ConsumerState<WeekCallsWidget> {
  @override
  Widget build(BuildContext context) {
    final weekCallsAsync = ref.watch(weekCallHistoryProvider);

    return weekCallsAsync.when(
      data: (weekCallsData) {
        if (weekCallsData.isEmpty) {
          return Center(
            child: Text(
              "No call history yet",
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: weekCallsData.length,
          itemBuilder: (context, index) {
            final data = weekCallsData[index];
            final formattedTime = DateFormat(
              'dd MMM yyyy, hh:mm a',
            ).format(data.createdAt.toDate());

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              color: const Color(0xFF121212),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row — caller and receiver
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${data.callerName} → ${data.receiverName}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        Icon(
                          data.isVideo
                              ? Icons.videocam_rounded
                              : Icons.call_rounded,
                          color: Colors.deepOrange,
                          size: 22.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),

                    // Duration and time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "${data.durationSeconds}s",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          formattedTime,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Divider
                    Divider(color: Colors.grey.shade800),

                    // Coins and share info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoTile(
                          "Coins Deducted",
                          "💰 ${data.coinsDeducted.toStringAsFixed(2)}",
                        ),
                        _infoTile("Admin", "₹${data.adminShare}"),
                        _infoTile("Receiver", "₹${data.receiverShare}"),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      error: (err, _) => Center(child: Text(err.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
      ],
    );
  }
}
