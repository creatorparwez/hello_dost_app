import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/providers/User/buy_coins_provider.dart';

class BuyCoinsScreen extends ConsumerStatefulWidget {
  const BuyCoinsScreen({super.key});

  @override
  ConsumerState<BuyCoinsScreen> createState() => _BuyCoinsScreenState();
}

class _BuyCoinsScreenState extends ConsumerState<BuyCoinsScreen> {
  int? selectedIndex; // Track selected card

  @override
  Widget build(BuildContext context) {
    final buyCoinsAsync = ref.watch(buyCoinsProvider);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 205, 205),
      appBar: AppBar(
        title: Text(
          "Buy Coins",
          style: TextStyle(color: Colors.white, fontSize: 26.sp),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 29, 28, 28),
      ),
      body: buyCoinsAsync.when(
        data: (buyCoinsData) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: buyCoinsData.length,
              itemBuilder: (context, index) {
                var data = buyCoinsData[index];
                bool isSelected = selectedIndex == index;
                return InkWell(
                  onTap: () {
                    // Payment Logics
                    setState(() {
                      selectedIndex = index; // update selected card
                    });
                  },
                  child: Card(
                    shadowColor: Colors.white,
                    elevation: 5,
                    color: const Color.fromARGB(255, 19, 22, 26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      side: isSelected
                          ? BorderSide(
                              color: Colors.white,
                              width: 4,
                            ) // white outline
                          : BorderSide(color: Colors.transparent, width: 0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/dollar.png',
                            height: 35.h,
                            width: 35.w,
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            data.coins.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28.sp,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Text(
                                "₹${data.originalPrice.toInt()}",
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.white,
                                  decorationThickness: 2,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                "₹${data.discountPrice.toString()}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        error: (err, _) => Center(child: Text(err.toString())),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
