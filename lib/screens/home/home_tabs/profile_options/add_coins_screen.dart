import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zee_goo/providers/User/buy_coins_provider.dart';

class AddCoinsScreen extends ConsumerStatefulWidget {
  final String userId;
  const AddCoinsScreen({super.key, required this.userId});

  @override
  ConsumerState<AddCoinsScreen> createState() => _BuyCoinsScreenState();
}

class _BuyCoinsScreenState extends ConsumerState<AddCoinsScreen> {
  int? selectedIndex; // Track selected card

  @override
  Widget build(BuildContext context) {
    final buyCoinsAsync = ref.watch(buyCoinsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Add Coins",
          style: TextStyle(color: Colors.white, fontSize: 26.sp),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 29, 28, 28),
      ),
      body: buyCoinsAsync.when(
        data: (buyCoinsData) {
          // Sort ascending
          buyCoinsData.sort((a, b) => a.coins.compareTo(b.coins));

          return Stack(
            children: [
              /// GridView
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                child: GridView.builder(
                  padding: EdgeInsets.only(
                    bottom: 100.h,
                  ), // space for floating btn
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Card(
                        shadowColor: Colors.white,
                        elevation: 5,
                        color: const Color.fromARGB(255, 19, 22, 26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          side: isSelected
                              ? const BorderSide(
                                  color: Colors.deepOrange,
                                  width: 3,
                                )
                              : BorderSide.none,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Colors.white,
                                      decorationThickness: 2,
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    "₹${data.discountPrice}",
                                    style: const TextStyle(color: Colors.white),
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
              ),

              /// Floating Button (visible when a card is selected)
              if (selectedIndex != null)
                Positioned(
                  bottom: 25.h,
                  left: 20.w,
                  right: 20.w,
                  child: GestureDetector(
                    onTap: () {
                      // Add Coins Logic
                      final selected = buyCoinsData[selectedIndex!];
                      Fluttertoast.showToast(
                        msg: "${selected.coins} coins added",
                        backgroundColor: Colors.deepOrange,
                        fontSize: 15.sp,
                      );
                      print("Add ${selected.coins} Coins clicked");
                    },
                    child: AnimatedOpacity(
                      opacity: selectedIndex != null ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        height: 55.h,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Add ${buyCoinsData[selectedIndex!].coins} Coins",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        error: (err, _) => Center(child: Text(err.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
