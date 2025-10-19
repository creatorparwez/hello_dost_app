import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeaderboardWidget extends ConsumerStatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  ConsumerState<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends ConsumerState<LeaderboardWidget> {
  @override
  Widget build(BuildContext context) {
    final topFemalesAsync = ref.watch(topFemalesProvider);

    return topFemalesAsync.when(
      data: (femaleData) {
        if (femaleData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 80.sp,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 16.h),
                Text(
                  "No Top Earners Yet",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Be the first to join the leaderboard!",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.pink.shade50,
                Colors.white,
              ],
            ),
          ),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            itemCount: femaleData.length,
            itemBuilder: (context, index) {
              final data = femaleData[index];
              final isTopThree = index < 3;

              // Rank colors and icons
              Color rankColor;
              IconData? medalIcon;
              Color? medalColor;

              switch (index) {
                case 0:
                  rankColor = Colors.amber.shade700;
                  medalIcon = Icons.workspace_premium;
                  medalColor = Colors.amber.shade700;
                  break;
                case 1:
                  rankColor = Colors.grey.shade400;
                  medalIcon = Icons.workspace_premium;
                  medalColor = Colors.grey.shade400;
                  break;
                case 2:
                  rankColor = Colors.orange.shade800;
                  medalIcon = Icons.workspace_premium;
                  medalColor = Colors.orange.shade800;
                  break;
                default:
                  rankColor = Colors.pink.shade300;
              }

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: isTopThree
                          ? rankColor.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: isTopThree ? 12 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: isTopThree
                      ? Border.all(color: rankColor.withOpacity(0.3), width: 2)
                      : null,
                ),
                child: Padding(
                  padding: EdgeInsets.all(isTopThree ? 16.w : 12.w),
                  child: Row(
                    children: [
                      // Rank Badge
                      Container(
                        width: isTopThree ? 50.w : 40.w,
                        height: isTopThree ? 50.w : 40.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isTopThree
                                ? [rankColor, rankColor.withOpacity(0.7)]
                                : [Colors.pink.shade200, Colors.pink.shade300],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: rankColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTopThree ? 20.sp : 16.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),

                      // Profile Image
                      Stack(
                        children: [
                          Container(
                            width: isTopThree ? 60.w : 50.w,
                            height: isTopThree ? 60.w : 50.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: rankColor,
                                width: isTopThree ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: rankColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: data.imagePath != null && data.imagePath!.isNotEmpty
                                  ? Image.asset(
                                      data.imagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.grey.shade400,
                                            size: isTopThree ? 30.sp : 25.sp,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey.shade400,
                                        size: isTopThree ? 30.sp : 25.sp,
                                      ),
                                    ),
                            ),
                          ),
                          if (isTopThree)
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  medalIcon,
                                  color: medalColor,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 16.w),

                      // Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.name,
                              style: TextStyle(
                                fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
                                fontSize: isTopThree ? 18.sp : 16.sp,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isTopThree) ...[
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: rankColor,
                                    size: 14.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    index == 0
                                        ? 'Top Performer'
                                        : index == 1
                                            ? 'Runner Up'
                                            : 'Third Place',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: rankColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Trophy Icon for top 3
                      if (isTopThree)
                        Icon(
                          Icons.emoji_events,
                          color: rankColor,
                          size: 28.sp,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60.sp,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              "Oops! Something went wrong",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Error: $err",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.pink.shade300),
            ),
            SizedBox(height: 16.h),
            Text(
              "Loading Leaderboard...",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
